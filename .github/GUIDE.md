# GitHub Actions Configuration Guide

This document explains how to configure the GitHub Actions workflow for your project with support for multiple DNS providers.

## Supported DNS Providers

| Provider | Plugin | Required Secrets |
|----------|--------|------------------|
| Cloudflare | `python3-certbot-dns-cloudflare` | `CF_API_TOKEN`, `CF_ZONE_ID` |
| AWS Route53 | `certbot-dns-route53` | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` |
| Google Cloud | `certbot-dns-google` | `GOOGLE_CREDENTIALS` |
| Azure | `certbot-dns-azure` | `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` |
| DigitalOcean | `certbot-dns-digitalocean` | `DO_API_TOKEN` |
| Linode | `certbot-dns-linode` | `LINODE_API_TOKEN` |
| OVH | `certbot-dns-ovh` | `OVH_APPLICATION_KEY`, `OVH_APPLICATION_SECRET`, `OVH_CONSUMER_KEY` |
| RFC 2136 | `certbot-dns-rfc2136` | `RFC2136_NAMESERVER`, `RFC2136_CREDENTIALS` |

## Required Variables

Go to **Settings → Secrets and variables → Actions → Variables → New repository variable**:

### LE_CERT_DOMAINS

- **Description**: Comma-separated list of domains for the certificate
- **Example**: `example.com,*.example.com,api.example.com`
- **Notes**: 
  - Use `*.example.com` for wildcard certificates
  - Include the base domain if needed
  - Maximum 100 domains per certificate

### LE_CERTBOT_EMAIL

- **Description**: Email address for Let's Encrypt registration
- **Example**: `admin@example.com`
- **Notes**: 
  - Used for certificate expiration notifications
  - Must be a valid email address

### LE_DNS_PROVIDER

- **Description**: DNS provider to use for validation
- **Default**: `cloudflare`
- **Options**: `cloudflare`, `route53`, `google`, `azure`, `digitalocean`, `linode`, `ovh`, `rfc2136`

## Provider-Specific Configuration

### Cloudflare

1. **Get API Token**:
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
   - Click profile icon → **My Profile**
   - Go to **API Tokens** → **Create Token**
   - Use **Edit zone DNS** template
   - Select your zone
   - Create and copy the token

2. **Get Zone ID**:
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
   - Select your domain
   - Go to **Overview** page
   - Scroll to **API** section
   - Copy **Zone ID**

3. **Add Secrets**:
   - `CF_API_TOKEN`: Your API token
   - `CF_ZONE_ID`: Your Zone ID

### AWS Route53

1. **Create IAM User**:
   - Go to [AWS IAM Console](https://console.aws.amazon.com/iam/)
   - Create a new user with programmatic access
   - Attach the following policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:GetChange",
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*",
        "arn:aws:route53:::change/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }
  ]
}
```

2. **Add Secrets**:
   - `AWS_ACCESS_KEY_ID`: Your access key ID
   - `AWS_SECRET_ACCESS_KEY`: Your secret access key

### Google Cloud DNS

1. **Create Service Account**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Go to **IAM & Admin** → **Service Accounts**
   - Create a new service account
   - Grant the role: **DNS Admin**
   - Create a JSON key and download it

2. **Add Secret**:
   - `GOOGLE_CREDENTIALS`: Paste the entire JSON content

### Azure DNS

1. **Create App Registration**:
   - Go to [Azure Portal](https://portal.azure.com/)
   - Go to **Azure Active Directory** → **App registrations**
   - Create a new registration
   - Create a client secret

2. **Grant Permissions**:
   - Go to your DNS Zone
   - Click **Access control (IAM)**
   - Add role assignment: **Contributor**

3. **Add Secrets**:
   - `AZURE_CLIENT_ID`: Application (client) ID
   - `AZURE_CLIENT_SECRET`: Client secret
   - `AZURE_TENANT_ID`: Directory (tenant) ID
   - `AZURE_SUBSCRIPTION_ID`: Subscription ID

### DigitalOcean

1. **Create API Token**:
   - Go to [DigitalOcean API](https://cloud.digitalocean.com/account/api/tokens)
   - Generate a new token
   - Select **Read and Write** scope

2. **Add Secret**:
   - `DO_API_TOKEN`: Your API token

### Linode

1. **Create API Token**:
   - Go to [Linode Manager](https://cloud.linode.com/profile/api/tokens)
   - Create a new personal access token
   - Select **Read/Write Access** for Domains

2. **Add Secret**:
   - `LINODE_API_TOKEN`: Your API token

### OVH

1. **Create API Credentials**:
   - Go to [OVH API](https://api.ovh.com/)
   - Create an application
   - Generate a consumer key
   - Grant the following rights:
     - `GET /domain/zone/*`
     - `PUT /domain/zone/*`
     - `POST /domain/zone/*`

2. **Add Secrets**:
   - `OVH_APPLICATION_KEY`: Application key
   - `OVH_APPLICATION_SECRET`: Application secret
   - `OVH_CONSUMER_KEY`: Consumer key

### RFC 2136

1. **Configure DNS Server**:
   - Ensure your DNS server supports RFC 2136 (TSIG)
   - Create a TSIG key for certbot

2. **Add Secrets**:
   - `RFC2136_NAMESERVER`: Your nameserver (e.g., `ns1.example.com`)
   - `RFC2136_CREDENTIALS`: TSIG key file content

## Workflow Inputs

When running the workflow manually, you can override the variables:

- **domains**: Comma-separated domains (overrides `LE_CERT_DOMAINS`)
- **email**: Email for Let's Encrypt registration (overrides `LE_CERTBOT_EMAIL`)
- **dns_provider**: DNS provider to use (overrides `LE_DNS_PROVIDER`)

## Schedule

The workflow runs automatically every 60 days:
```yaml
cron: "0 3 1 */2 *"
```

This means:
- Day 1 of every 2nd month
- At 03:00 UTC

To change the schedule, edit `.github/workflows/certificate.yml`:

```yaml
schedule:
  # Every month
  cron: "0 3 1 * *"
  
  # Every week
  cron: "0 3 * * 1"
  
  # Every day
  cron: "0 3 * * *"
```

## Permissions

The workflow requires `contents: write` permission to:
- Commit certificate files to the repository
- Push changes to the default branch

This is configured in the workflow file:
```yaml
permissions:
  contents: write
```

## Troubleshooting

### "DOMAINS is not set"

- Ensure `LE_CERT_DOMAINS` variable is set in GitHub
- Or provide domains when running the workflow manually

### "CERTBOT_EMAIL is not set"

- Ensure `LE_CERTBOT_EMAIL` variable is set in GitHub
- Or provide email when running the workflow manually

### "DNS provider credentials required"

- Ensure the required secrets for your provider are set
- Verify the credentials are correct

### "DNS problem: NXDOMAIN looking up TXT"

- Wait a few minutes for DNS propagation
- Verify the API token has correct permissions
- Check that the credentials match the correct domain/zone

### "Too many certificates already issued"

- Let's Encrypt has rate limits (50 certificates per domain per week)
- Use a different domain for testing
- Wait 7 days before trying again

### "Plugin not installed"

- The certbot plugin for your provider is not installed
- The workflow installs it automatically, but you can install manually:
  ```bash
  pip3 install certbot-dns-<provider>
  ```