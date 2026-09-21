# Session Handoff

## Resume block (read first)

- Repo state: branch `main`, HEAD `(initial)`, working tree `dirty: new files`
- Source of truth: `AGENTS.md` → `.ai/`
- Budget / usage observed: `unknown`
- Checkpoint updated: `2026-09-21`
- Last goal: `Montar estrutura de pipeline para geração de certificados Let's Encrypt`
- Exact next action: `Configurar Secrets no GitHub (CF_API_TOKEN, CF_ZONE_ID) e Variables (LE_CERT_DOMAINS, LE_CERTBOT_EMAIL), depois testar o workflow`
- Blocked by: `Credenciais Cloudflare (secrets) ainda não configuradas no GitHub`
- Resume prompt: `Read AGENTS.md and .ai/HANDOFF.md. Continue from the Resume block. Do not rediscover context.`

## Goal

Pipeline CI/CD que gera certificados Let's Encrypt via GitHub Actions com validação DNS-01 (Cloudflare), retornando os arquivos `.pem` como artifacts.

## Current State

Estrutura criada, aguardando configuração de secrets e teste.

## What Was Done

- Criado `scripts/generate-cert.sh` — script bash com certbot + DNS-01 Cloudflare
- Criado `.github/workflows/certificate.yml` — pipeline completa com trigger manual e cron
- Criado `.gitignore` — exclusão de .pem e artifacts
- Criado `README.md` — documentação de uso e configuração
- Atualizado `.ai/` context (PROJECT, ARCHITECTURE, CONVENTIONS)

## Files Changed

- `scripts/generate-cert.sh` (novo)
- `.github/workflows/certificate.yml` (novo)
- `.gitignore` (novo)
- `README.md` (novo)
- `.ai/PROJECT.md` (atualizado)
- `.ai/ARCHITECTURE.md` (atualizado)
- `.ai/CONVENTIONS.md` (atualizado)

## Decisions Made

- **ACME client:** certbot (padrão da indústria, plugin Cloudflare nativo)
- **Key type:** ECDSA P-256 (mais rápido que RSA)
- **Validação:** DNS-01 via Cloudflare (suporta wildcards)
- **Entrega:** GitHub Artifacts + commit automático via bot
- **Renovação:** Cron bimestral (certs duram 90 dias)

## Problems / Risks

- Secrets `CF_API_TOKEN` e `CF_ZONE_ID` precisam ser criados no GitHub antes do primeiro uso
- Cloudflare token precisa das permissões: `Zone.Zone:Read`, `Zone.DNS:Edit`

## Validation Performed

- Estrutura de diretórios criada e verificada
- Scripts com `set -euo pipefail` para tratamento de erros

## Next Actions

1. Criar token Cloudflare com permissões de DNS
2. Configurar secrets no GitHub (Settings → Secrets → Actions)
3. Configurar variables no GitHub (Settings → Variables → Actions)
4. Testar o workflow via `workflow_dispatch`
5. Verificar artifact gerado e conteúdo dos .pem
