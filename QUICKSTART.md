# Quick Start Guide

Get up and running with the Let's Encrypt Certificate Pipeline in minutes.

## Prerequisites

- GitHub account
- Cloudflare account with DNS management
- Domain name pointed to Cloudflare

## Step 1: Fork the Repository

1. Go to the repository page
2. Click **Fork** button
3. Select your GitHub account
4. Wait for the fork to complete

## Step 2: Configure GitHub Secrets

1. Go to your forked repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add:

### CF_API_TOKEN

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Click profile icon → **My Profile**
3. Go to **API Tokens** → **Create Token**
4. Use **Edit zone DNS** template
5. Select your zone
6. Create and copy the token
7. Add as `CF_API_TOKEN` in GitHub Secrets

### CF_ZONE_ID

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Select your domain
3. Go to **Overview** page
4. Scroll to **API** section
5. Copy **Zone ID**
6. Add as `CF_ZONE_ID` in GitHub Secrets

## Step 3: Configure GitHub Variables

1. Go to **Settings** → **Secrets and variables** → **Actions** → **Variables**
2. Click **New repository variable** and add:

### LE_CERT_DOMAINS

- **Value**: `example.com,*.example.com` (replace with your domain)
- **Description**: Domains for the certificate

### LE_CERTBOT_EMAIL

- **Value**: `your-email@example.com`
- **Description**: Email for Let's Encrypt registration

## Step 4: Run the Workflow

1. Go to **Actions** → **Generate Let's Encrypt Certificate**
2. Click **Run workflow**
3. Fill in:
   - **Domains**: `example.com,*.example.com` (or leave empty to use variable)
   - **Email**: `your-email@example.com` (or leave empty to use variable)
4. Click **Run workflow**

## Step 5: Download Certificate

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

## Step 6: Use the Certificate

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

### "Cloudflare credentials required"

Verify `CF_API_TOKEN` and `CF_ZONE_ID` secrets are set correctly.

### "DNS problem: NXDOMAIN"

- Wait a few minutes for DNS propagation
- Verify Cloudflare API token has `Zone.DNS:Edit` permission

## Next Steps

- Read the full [README](README.md) for detailed configuration
- Check [GitHub Actions Guide](.github/GUIDE.md) for advanced options
- See [Contributing Guide](CONTRIBUTING.md) to help improve the project

## Need Help?

- Open an issue on GitHub
- Check existing issues for solutions
- Read the documentation