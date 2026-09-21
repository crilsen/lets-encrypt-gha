# GitHub Actions Configuration Guide

This document explains how to configure the GitHub Actions workflow for your project.

## Required Secrets

Go to **Settings → Secrets and variables → Actions → New repository secret**:

### CF_API_TOKEN

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Click on your profile icon → **My Profile**
3. Go to **API Tokens** tab
4. Click **Create Token**
5. Use the **Edit zone DNS** template
6. Select the appropriate zone
7. Click **Continue to summary**
8. Click **Create Token**
9. Copy the token and add it as `CF_API_TOKEN` in GitHub Secrets

### CF_ZONE_ID

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Select your domain
3. Go to **Overview** page
4. Scroll down to **API** section
5. Copy the **Zone ID**
6. Add it as `CF_ZONE_ID` in GitHub Secrets

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

## Workflow Inputs

When running the workflow manually, you can override the variables:

- **domains**: Comma-separated domains (overrides `LE_CERT_DOMAINS`)
- **email**: Email for Let's Encrypt registration (overrides `LE_CERTBOT_EMAIL`)

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

### "Cloudflare credentials required"

- Ensure `CF_API_TOKEN` and `CF_ZONE_ID` secrets are set
- Verify the API token has correct permissions

### "DNS problem: NXDOMAIN looking up TXT"

- Wait a few minutes for DNS propagation
- Verify the Cloudflare API token has `Zone.DNS:Edit` permission
- Check that the Zone ID matches the correct domain

### "Too many certificates already issued"

- Let's Encrypt has rate limits (50 certificates per domain per week)
- Use a different domain for testing
- Wait 7 days before trying again