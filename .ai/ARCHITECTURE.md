# Architecture

## Current repository architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Actions                           │
│                                                             │
│  workflow_dispatch ──┐                                      │
│  schedule (cron) ────┤                                      │
│                      ▼                                      │
│              ┌──────────────┐                               │
│              │   generate   │                               │
│              │   job        │                               │
│              └──────┬───────┘                               │
│                     │                                       │
│     ┌───────────────┼───────────────┐                       │
│     ▼               ▼               ▼                       │
│ ┌────────┐   ┌────────────┐  ┌──────────────┐              │
│ │ validate│   │  install   │  │   generate   │              │
│ │ inputs  │   │  certbot   │  │   cert       │              │
│ └────────┘   └────────────┘  └──────┬───────┘              │
│                                      │                      │
│                    ┌─────────────────┼─────────────────┐    │
│                    ▼                 ▼                 ▼    │
│              ┌──────────┐    ┌───────────┐   ┌──────────┐  │
│              │  verify  │    │  upload   │   │  commit  │  │
│              │  certs   │    │ artifact  │   │  to repo │  │
│              └──────────┘    └───────────┘   └──────────┘  │
└─────────────────────────────────────────────────────────────┘

External services:
  • Let's Encrypt ACME API (certificate issuance)
  • Cloudflare API (DNS-01 challenge via TXT records)
```

### Components

| Component | Description |
|-----------|-------------|
| `.github/workflows/certificate.yml` | Orchestration: triggers, validation, cert generation, artifact upload |
| `scripts/generate-cert.sh` | Core logic: installs certbot, creates DNS challenge, requests cert |
| `output/certs/` | Generated certificate files (committed by bot, excluded from local `.gitignore`) |

### Secrets & Variables

- **Secrets:** `CF_API_TOKEN`, `CF_ZONE_ID` — Cloudflare API credentials
- **Variables:** `LE_CERT_DOMAINS`, `LE_CERTBOT_EMAIL` — Domain list and registration email

## Context-layer layout

```text
Tool-specific adapter (optional)
            ↓
        AGENTS.md
            ↓
          .ai/
  project · architecture · conventions · decisions
  tasks · handoff · tools · validation · workflows · prompts
```

`.ai/` is the portable source of truth. Tool-specific adapters must only route agents to it.

## Recommended convention

Document the architecture that exists, not an idealized future design. Mark facts as observed, inferences as inferred, proposed patterns as recommended, and unavailable facts as unknown.
