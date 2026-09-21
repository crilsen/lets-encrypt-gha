# Project

## Identity

- **Name:** lets-encrypt-ga
- **Objective:** Automated Let's Encrypt certificate generation pipeline using GitHub Actions with Cloudflare DNS-01 validation.
- **Repository purpose:** Provide a reusable, open-source template for automated SSL/TLS certificate management.
- **Status:** Production-ready template with comprehensive documentation.

## Observed

- **Purpose:** CI/CD pipeline for automated Let's Encrypt certificate generation via GitHub Actions.
- **Technologies:** Shell script (bash), certbot + python3-certbot-dns-cloudflare, GitHub Actions, Cloudflare DNS API.
- **Validation method:** DNS-01 via Cloudflare API token (supports wildcards and multiple SANs).
- **Key type:** ECDSA (secp256r1/P-256) — faster and more secure than RSA.
- **Output:** `.pem` files (certificate, private-key, chain, fullchain) via GitHub Artifacts.
- **Schedule:** Automatic bimonthly renewal via cron (`0 3 1 */2 *`), with manual trigger available.

## Template priorities

- Context belongs to the repository and travels with Git.
- Keep documentation concise, evidence-based, and non-duplicative.
- Prefer safe semi-autonomous work: exploration, scoped edits, formatting, linting, tests, and validation are allowed; impactful external operations require explicit approval.

## Recommended convention

When this template is adopted by a project, replace only the unknown sections with observed facts, link to authoritative existing documentation, and keep this file an overview rather than a duplicate README.