#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────
# Let's Encrypt Certificate Generator
# DNS-01 validation via Cloudflare API
# Output: certificate, private key, and full chain
# ──────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/../output"
CERT_NAME="${CERT_NAME:-letsencrypt-cert}"

# ── Validation ──────────────────────────────────────────────
if [[ -z "${DOMAINS:-}" ]]; then
  echo "ERROR: DOMAINS env var is required."
  echo "  Example: DOMAINS='example.com,api.example.com,www.example.com'"
  exit 1
fi

if [[ -z "${CF_Token:-}" || -z "${CF_Zone_ID:-}" ]]; then
  echo "ERROR: Cloudflare credentials required."
  echo "  Set CF_Token and CF_Zone_ID environment variables."
  exit 1
fi

if [[ -z "${CERTBOT_EMAIL:-}" ]]; then
  echo "ERROR: CERTBOT_EMAIL is required (Let's Encrypt registration email)."
  exit 1
fi

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
echo "║  Domains: ${DOMAINS}"
echo "║  Email:   ${CERTBOT_EMAIL}"
echo "║  Output:  ${OUTPUT_DIR}"
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

# ── Create Cloudflare credentials file ──────────────────────
CF_CRED_FILE=$(mktemp)
cat > "${CF_CRED_FILE}" <<EOF
dns_cloudflare_api_token = ${CF_Token}
EOF
trap 'rm -f "${CF_CRED_FILE}"' EXIT

echo "[2/4] Requesting certificate from Let's Encrypt..."

# ── Request certificate ─────────────────────────────────────
certbot certonly \
  --non-interactive \
  --agree-tos \
  --email "${CERTBOT_EMAIL}" \
  --dns-cloudflare \
  --dns-cloudflare-credentials "${CF_CRED_FILE}" \
  --dns-cloudflare-propagation-seconds 30 \
  --cert-name "${CERT_NAME}" \
  ${DOMAIN_ARGS} \
  --key-type ecdsa \
  --elliptic-curve secp256r1 \
  --work-dir "${OUTPUT_DIR}/.certbot-work" \
  --config-dir "${OUTPUT_DIR}/.certbot-config" \
  --logs-dir "${OUTPUT_DIR}/.certbot-logs"

echo "[3/4] Copying certificate files to output..."

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

echo "[4/4] Certificate generated successfully!"

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