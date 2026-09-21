#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────
# Let's Encrypt Certificate Generator
# DNS-01 validation via multiple providers
# Output: certificate, private key, and full chain
# ──────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/../output"
CERT_NAME="${CERT_NAME:-letsencrypt-cert}"
DNS_PROVIDER="${DNS_PROVIDER:-cloudflare}"

# ── Validation ──────────────────────────────────────────────
if [[ -z "${DOMAINS:-}" ]]; then
  echo "ERROR: DOMAINS env var is required."
  echo "  Example: DOMAINS='example.com,api.example.com,www.example.com'"
  exit 1
fi

if [[ -z "${CERTBOT_EMAIL:-}" ]]; then
  echo "ERROR: CERTBOT_EMAIL is required (Let's Encrypt registration email)."
  exit 1
fi

# ── Provider-specific validation ────────────────────────────
validate_cloudflare() {
  if [[ -z "${CF_Token:-}" || -z "${CF_Zone_ID:-}" ]]; then
    echo "ERROR: Cloudflare credentials required."
    echo "  Set CF_Token and CF_Zone_ID environment variables."
    exit 1
  fi
}

validate_route53() {
  if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
    echo "ERROR: AWS credentials required."
    echo "  Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables."
    exit 1
  fi
}

validate_google() {
  if [[ -z "${GOOGLE_CREDENTIALS:-}" ]]; then
    echo "ERROR: Google Cloud credentials required."
    echo "  Set GOOGLE_CREDENTIALS environment variable (path to JSON credentials file)."
    exit 1
  fi
  if [[ ! -f "${GOOGLE_CREDENTIALS}" ]]; then
    echo "ERROR: Google Cloud credentials file not found: ${GOOGLE_CREDENTIALS}"
    exit 1
  fi
}

validate_azure() {
  if [[ -z "${AZURE_CLIENT_ID:-}" || -z "${AZURE_CLIENT_SECRET:-}" || -z "${AZURE_TENANT_ID:-}" || -z "${AZURE_SUBSCRIPTION_ID:-}" ]]; then
    echo "ERROR: Azure credentials required."
    echo "  Set AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_TENANT_ID, and AZURE_SUBSCRIPTION_ID environment variables."
    exit 1
  fi
}

validate_digitalocean() {
  if [[ -z "${DO_API_TOKEN:-}" ]]; then
    echo "ERROR: DigitalOcean API token required."
    echo "  Set DO_API_TOKEN environment variable."
    exit 1
  fi
}

validate_linode() {
  if [[ -z "${LINODE_API_TOKEN:-}" ]]; then
    echo "ERROR: Linode API token required."
    echo "  Set LINODE_API_TOKEN environment variable."
    exit 1
  fi
}

validate_ovh() {
  if [[ -z "${OVH_APPLICATION_KEY:-}" || -z "${OVH_APPLICATION_SECRET:-}" || -z "${OVH_CONSUMER_KEY:-}" ]]; then
    echo "ERROR: OVH credentials required."
    echo "  Set OVH_APPLICATION_KEY, OVH_APPLICATION_SECRET, and OVH_CONSUMER_KEY environment variables."
    exit 1
  fi
}

validate_rfc2136() {
  if [[ -z "${RFC2136_NAMESERVER:-}" || -z "${RFC2136_CREDENTIALS:-}" ]]; then
    echo "ERROR: RFC 2136 credentials required."
    echo "  Set RFC2136_NAMESERVER and RFC2136_CREDENTIALS environment variables."
    exit 1
  fi
  if [[ ! -f "${RFC2136_CREDENTIALS}" ]]; then
    echo "ERROR: RFC 2136 credentials file not found: ${RFC2136_CREDENTIALS}"
    exit 1
  fi
}

# Validate provider
case "${DNS_PROVIDER}" in
  cloudflare) validate_cloudflare ;;
  route53) validate_route53 ;;
  google) validate_google ;;
  azure) validate_azure ;;
  digitalocean) validate_digitalocean ;;
  linode) validate_linode ;;
  ovh) validate_ovh ;;
  rfc2136) validate_rfc2136 ;;
  *)
    echo "ERROR: Unsupported DNS provider: ${DNS_PROVIDER}"
    echo "  Supported providers: cloudflare, route53, google, azure, digitalocean, linode, ovh, rfc2136"
    exit 1
    ;;
esac

# ── Prepare ─────────────────────────────────────────────────
mkdir -p "${OUTPUT_DIR}"

# Convert comma-separated domains to -d flags
DOMAIN_ARGS=""
IFS=',' read -ra DOMAIN_ARRAY <<< "${DOMAINS}"
for domain in "${DOMAIN_ARRAY[@]}"; do
  domain="$(echo "${domain}" | xargs)" # trim whitespace
  DOMAIN_ARGS="${DOMAIN_ARGS} -d ${domain}"
done

echo "╔══════════════════════════════════════════════════════╗"
echo "║       Let's Encrypt Certificate Generator           ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Domains:  ${DOMAINS}"
echo "║  Email:    ${CERTBOT_EMAIL}"
echo "║  Provider: ${DNS_PROVIDER}"
echo "║  Output:   ${OUTPUT_DIR}"
echo "╚══════════════════════════════════════════════════════╝"

# ── Install certbot if missing ──────────────────────────────
if ! command -v certbot &>/dev/null; then
  echo "[1/4] Installing certbot..."
  if command -v apt-get &>/dev/null; then
    apt-get update -qq && apt-get install -y -qq certbot python3-certbot-dns-cloudflare >/dev/null
  elif command -v brew &>/dev/null; then
    brew install certbot >/dev/null 2>&1
  else
    echo "ERROR: Cannot install certbot automatically. Please install it manually."
    exit 1
  fi
fi

# ── Install provider plugin ────────────────────────────────
install_provider_plugin() {
  local plugin=""
  
  case "${DNS_PROVIDER}" in
    cloudflare) plugin="python3-certbot-dns-cloudflare" ;;
    route53) plugin="certbot-dns-route53" ;;
    google) plugin="certbot-dns-google" ;;
    azure) plugin="certbot-dns-azure" ;;
    digitalocean) plugin="certbot-dns-digitalocean" ;;
    linode) plugin="certbot-dns-linode" ;;
    ovh) plugin="certbot-dns-ovh" ;;
    rfc2136) plugin="certbot-dns-rfc2136" ;;
  esac
  
  if [[ -n "${plugin}" ]]; then
    echo "[2/4] Installing ${DNS_PROVIDER} plugin..."
    if command -v pip3 &>/dev/null; then
      pip3 install "${plugin}" >/dev/null 2>&1
    elif command -v pip &>/dev/null; then
      pip install "${plugin}" >/dev/null 2>&1
    else
      echo "ERROR: pip not found. Please install ${plugin} manually."
      exit 1
    fi
  fi
}

install_provider_plugin

# ── Create provider credentials file ────────────────────────
create_cloudflare_credentials() {
  CF_CRED_FILE=$(mktemp)
  cat > "${CF_CRED_FILE}" <<EOF
dns_cloudflare_api_token = ${CF_Token}
EOF
  echo "${CF_CRED_FILE}"
}

create_route53_credentials() {
  # Route53 uses AWS credentials from environment
  echo ""
}

create_google_credentials() {
  echo "${GOOGLE_CREDENTIALS}"
}

create_azure_credentials() {
  AZURE_CRED_FILE=$(mktemp)
  cat > "${AZURE_CRED_FILE}" <<EOF
dns_azure_subscription_id = ${AZURE_SUBSCRIPTION_ID}
dns_azure_tenant_id = ${AZURE_TENANT_ID}
dns_azure_client_id = ${AZURE_CLIENT_ID}
dns_azure_client_secret = ${AZURE_CLIENT_SECRET}
EOF
  echo "${AZURE_CRED_FILE}"
}

create_digitalocean_credentials() {
  DO_CRED_FILE=$(mktemp)
  cat > "${DO_CRED_FILE}" <<EOF
dns_digitalocean_token = ${DO_API_TOKEN}
EOF
  echo "${DO_CRED_FILE}"
}

create_linode_credentials() {
  LINODE_CRED_FILE=$(mktemp)
  cat > "${LINODE_CRED_FILE}" <<EOF
dns_linode_token = ${LINODE_API_TOKEN}
EOF
  echo "${LINODE_CRED_FILE}"
}

create_ovh_credentials() {
  OVH_CRED_FILE=$(mktemp)
  cat > "${OVH_CRED_FILE}" <<EOF
dns_ovh_application_key = ${OVH_APPLICATION_KEY}
dns_ovh_application_secret = ${OVH_APPLICATION_SECRET}
dns_ovh_consumer_key = ${OVH_CONSUMER_KEY}
EOF
  echo "${OVH_CRED_FILE}"
}

create_rfc2136_credentials() {
  echo "${RFC2136_CREDENTIALS}"
}

# Create credentials and build certbot command
CERTBOT_ARGS=""

case "${DNS_PROVIDER}" in
  cloudflare)
    CF_CRED_FILE=$(create_cloudflare_credentials)
    trap 'rm -f "${CF_CRED_FILE}"' EXIT
    CERTBOT_ARGS="--dns-cloudflare --dns-cloudflare-credentials ${CF_CRED_FILE} --dns-cloudflare-propagation-seconds 30"
    ;;
  route53)
    CERTBOT_ARGS="--dns-route53"
    ;;
  google)
    GOOGLE_CRED_FILE=$(create_google_credentials)
    CERTBOT_ARGS="--dns-google --dns-google-credentials ${GOOGLE_CRED_FILE}"
    ;;
  azure)
    AZURE_CRED_FILE=$(create_azure_credentials)
    trap 'rm -f "${AZURE_CRED_FILE}"' EXIT
    CERTBOT_ARGS="--dns-azure --dns-azure-config ${AZURE_CRED_FILE}"
    ;;
  digitalocean)
    DO_CRED_FILE=$(create_digitalocean_credentials)
    trap 'rm -f "${DO_CRED_FILE}"' EXIT
    CERTBOT_ARGS="--dns-digitalocean --dns-digitalocean-credentials ${DO_CRED_FILE} --dns-digitalocean-propagation-seconds 30"
    ;;
  linode)
    LINODE_CRED_FILE=$(create_linode_credentials)
    trap 'rm -f "${LINODE_CRED_FILE}"' EXIT
    CERTBOT_ARGS="--dns-linode --dns-linode-credentials ${LINODE_CRED_FILE} --dns-linode-propagation-seconds 30"
    ;;
  ovh)
    OVH_CRED_FILE=$(create_ovh_credentials)
    trap 'rm -f "${OVH_CRED_FILE}"' EXIT
    CERTBOT_ARGS="--dns-ovh --dns-ovh-credentials ${OVH_CRED_FILE} --dns-ovh-propagation-seconds 30"
    ;;
  rfc2136)
    RFC2136_CRED_FILE=$(create_rfc2136_credentials)
    CERTBOT_ARGS="--dns-rfc2136 --dns-rfc2136-credentials ${RFC2136_CRED_FILE} --dns-rfc2136-propagation-seconds 30"
    ;;
esac

echo "[3/4] Requesting certificate from Let's Encrypt..."

# ── Request certificate ─────────────────────────────────────
certbot certonly \
  --non-interactive \
  --agree-tos \
  --email "${CERTBOT_EMAIL}" \
  ${CERTBOT_ARGS} \
  --cert-name "${CERT_NAME}" \
  ${DOMAIN_ARGS} \
  --key-type ecdsa \
  --elliptic-curve secp256r1 \
  --work-dir "${OUTPUT_DIR}/.certbot-work" \
  --config-dir "${OUTPUT_DIR}/.certbot-config" \
  --logs-dir "${OUTPUT_DIR}/.certbot-logs"

echo "[4/4] Copying certificate files to output..."

# ── Copy output files ───────────────────────────────────────
CERT_DIR="${OUTPUT_DIR}/certs"
mkdir -p "${CERT_DIR}"

CERTBOT_LIVE="${OUTPUT_DIR}/.certbot-config/live/${CERT_NAME}"

cp "${CERTBOT_LIVE}/cert.pem"       "${CERT_DIR}/certificate.pem"
cp "${CERTBOT_LIVE}/privkey.pem"    "${CERT_DIR}/private-key.pem"
cp "${CERTBOT_LIVE}/chain.pem"      "${CERT_DIR}/chain.pem"
cp "${CERTBOT_LIVE}/fullchain.pem"  "${CERT_DIR}/fullchain.pem"

# ── Cleanup certbot internals ───────────────────────────────
rm -rf "${OUTPUT_DIR}/.certbot-work" "${OUTPUT_DIR}/.certbot-config" "${OUTPUT_DIR}/.certbot-logs"

echo "[5/5] Certificate generated successfully!"

# ── Summary ─────────────────────────────────────────────────
echo ""
echo "Certificate files:"
echo "  certificate.pem  - Server certificate"
echo "  private-key.pem  - Private key (KEEP SECRET)"
echo "  chain.pem        - Intermediate certificates"
echo "  fullchain.pem    - Certificate + chain (use this for web servers)"
echo ""
echo "Location: ${CERT_DIR}/"

# ── Output file listing for CI ──────────────────────────────
if [[ "${GITHUB_ACTIONS:-}" == "true" ]]; then
  echo ""
  echo "## Certificate Files" >> "${GITHUB_STEP_SUMMARY:-/dev/null}"
  echo '```' >> "${GITHUB_STEP_SUMMARY:-/dev/null}"
  ls -la "${CERT_DIR}/" >> "${GITHUB_STEP_SUMMARY:-/dev/null}"
  echo '```' >> "${GITHUB_STEP_SUMMARY:-/dev/null}"
fi