# Project

## Identity

- **Name:** ai-agent-relay
- **Objective:** A versioned, portable context layer that lets coding agents and agentic harnesses resume work without platform-specific chat history.
- **Repository purpose:** Provide a reusable template to embed in a project repository.
- **Status:** Initial context template; no application or infrastructure implementation is present.

## Observed

- **Purpose:** Pipeline CI/CD para geração automatizada de certificados Let's Encrypt via GitHub Actions.
- **Technologies:** Shell script (bash), certbot + python3-certbot-dns-cloudflare, GitHub Actions, Cloudflare DNS API.
- **Validation method:** DNS-01 via Cloudflare API token (suporta wildcard e múltiplos SANs).
- **Key type:** ECDSA (secp256r1/P-256) — mais rápido e seguro que RSA.
- **Output:** Arquivos `.pem` (certificate, private-key, chain, fullchain) via GitHub Artifacts.
- **Schedule:** Renovação automática bimestral via cron (`0 3 1 */2 *`), com trigger manual disponível.

## Template priorities

- Context belongs to the repository and travels with Git.
- Keep documentation concise, evidence-based, and non-duplicative.
- Prefer safe semi-autonomous work: exploration, scoped edits, formatting, linting, tests, and validation are allowed; impactful external operations require explicit approval.

## Recommended convention

When this template is adopted by a project, replace only the unknown sections with observed facts, link to authoritative existing documentation, and keep this file an overview rather than a duplicate README.
