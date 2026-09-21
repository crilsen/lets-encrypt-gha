# Quick Start Guide

Get up and running with the Let's Encrypt Certificate Pipeline in minutes.

## Prerequisites

- GitHub account
- DNS provider account (Cloudflare, AWS, Google Cloud, Azure, DigitalOcean, Linode, OVH, or RFC 2136)
- Domain name pointed to your DNS provider

## Step 1: Fork the Repository

1. Go to the repository page
2. Click **Fork** button
3. Select your GitHub account
4. Wait for the fork to complete

## Step 2: Choose Your DNS Provider

Select one of the supported providers:

| Provider | Best For | Difficulty |
|----------|----------|------------|
| **Cloudflare** | Most users, free tier available | Easy |
| **AWS Route53** | AWS users, enterprise | Medium |
| **Google Cloud** | GCP users | Medium |
| **Azure** | Azure users | Medium |
| **DigitalOcean** | Simple setup | Easy |
| **Linode** | Simple setup | Easy |
| **OVH** | European users | Medium |
| **RFC 2136** | Self-hosted DNS | Advanced |

## Step 3: Configure GitHub Secrets

Go to your forked repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

### Cloudflare (Recommended)

1. **Get API Token**:
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
   - Click profile icon → **My Profile**
   - Go to **API Tokens** → **Create Token**
   - Use **Edit zone DNS** template
   - Select your zone
   - Create and copy the token

2. **Get Zone ID**:
   - Go to your domain in Cloudflare
   - Go to **Overview** page
   - Copy **Zone ID** from API section

3. **Add Secrets**:
   - `CF_API_TOKEN`: Your API token
   - `CF_ZONE_ID`: Your Zone ID

### AWS Route53

1. **Create IAM User**:
   - Go to [AWS IAM Console](https://console.aws.amazon.com/iam/)
   - Create a new user with programmatic access
   - Attach the policy from the [guide](.github/GUIDE.md)

2. **Add Secrets**:
   - `AWS_ACCESS_KEY_ID`: Your access key ID
   - `AWS_SECRET_ACCESS_KEY`: Your secret access key

### Google Cloud DNS

1. **Create Service Account**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Go to **IAM & Admin** → **Service Accounts**
   - Create a new service account with **DNS Admin** role
   - Create a JSON key

2. **Add Secret**:
   - `GOOGLE_CREDENTIALS`: Paste the entire JSON content

### Azure DNS

1. **Create App Registration**:
   - Go to [Azure Portal](https://portal.azure.com/)
   - Go to **Azure Active Directory** → **App registrations**
   - Create a new registration
   - Create a client secret

2. **Grant Permissions**:
   - Go to your DNS Zone → **Access control (IAM)**
   - Add role assignment: **Contributor**

3. **Add Secrets**:
   - `AZURE_CLIENT_ID`: Application (client) ID
   - `AZURE_CLIENT_SECRET`: Client secret
   - `AZURE_TENANT_ID`: Directory (tenant) ID
   - `AZURE_SUBSCRIPTION_ID`: Subscription ID

### DigitalOcean

1. **Create API Token**:
   - Go to [DigitalOcean API](https://cloud.digitalocean.com/account/api/tokens)
   - Generate a new token with **Read and Write** scope

2. **Add Secret**:
   - `DO_API_TOKEN`: Your API token

### Linode

1. **Create API Token**:
   - Go to [Linode Manager](https://cloud.linode.com/profile/api/tokens)
   - Create a new personal access token with **Read/Write Access** for Domains

2. **Add Secret**:
   - `LINODE_API_TOKEN`: Your API token

### OVH

1. **Create API Credentials**:
   - Go to [OVH API](https://api.ovh.com/)
   - Create an application
   - Generate a consumer key with required rights

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

## Step 4: Configure GitHub Variables

Go to **Settings** → **Secrets and variables** → **Actions** → **Variables** → **New repository variable**

### LE_CERT_DOMAINS

- **Value**: `example.com,*.example.com` (replace with your domain)
- **Description**: Domains for the certificate

### LE_CERTBOT_EMAIL

- **Value**: `your-email@example.com`
- **Description**: Email for Let's Encrypt registration

### LE_DNS_PROVIDER

- **Value**: `cloudflare` (or your chosen provider)
- **Description**: DNS provider for validation

## Step 5: Run the Workflow

1. Go to **Actions** → **Generate Let's Encrypt Certificate**
2. Click **Run workflow**
3. Fill in:
   - **Domains**: `example.com,*.example.com` (or leave empty to use variable)
   - **Email**: `your-email@example.com` (or leave empty to use variable)
   - **DNS Provider**: Select your provider
4. Click **Run workflow**

## Step 6: Download Certificate

1. Wait for the workflow to complete (usually 2-3 minutes)
2. Click on the completed workflow run
3. Scroll to **Artifacts** section
4. Download `letsencrypt-certificate-<run-number>`
5. Extract the ZIP file

You now have:
- `certificate.pem` — Server certificate
- `private-key.pem` — Private key (keep secret!)
- `chain.pem` — Intermediate certificates
- `fullchain.pem` — Certificate + chain (use this)

## Step 7: Use the Certificate

### For Nginx

```nginx
server {
    listen 443 ssl;
    server_name example.com;
    
    ssl_certificate /path/to/fullchain.pem;
    ssl_certificate_key /path/to/private-key.pem;
    
    # ... other configuration
}
```

### For Apache

```apache
<VirtualHost *:443>
    ServerName example.com
    
    SSLEngine on
    SSLCertificateFile /path/to/certificate.pem
    SSLCertificateKeyFile /path/to/private-key.pem
    SSLCertificateChainFile /path/to/chain.pem
    
    # ... other configuration
</VirtualHost>
```

### For Node.js

```javascript
const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('private-key.pem'),
  cert: fs.readFileSync('fullchain.pem')
};

https.createServer(options, app).listen(443);
```

## Automatic Renewal

The workflow runs automatically every 60 days. No action needed!

## Troubleshooting

### "DOMAINS is not set"

Make sure you set `LE_CERT_DOMAINS` variable or provide domains when running manually.

### "DNS provider credentials required"

Verify the required secrets for your provider are set correctly.

### "DNS problem: NXDOMAIN"

- Wait a few minutes for DNS propagation
- Verify API token has correct permissions

### "Plugin not installed"

The workflow installs the plugin automatically. If it fails:
```bash
pip3 install certbot-dns-<provider>
```

## Next Steps

- Read the full [README](README.md) for detailed configuration
- Check [GitHub Actions Guide](.github/GUIDE.md) for advanced options
- See [Contributing Guide](CONTRIBUTING.md) to help improve the project

## Need Help?

- Open an issue on GitHub
- Check existing issues for solutions
- Read the documentation