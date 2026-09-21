# Let's Encrypt Certificate Pipeline

Geração automatizada de certificados Let's Encrypt via GitHub Actions, com validação DNS-01 (Cloudflare) e suporte a múltiplos SANs.

## Estrutura

```
├── .github/workflows/
│   └── certificate.yml      # Pipeline principal
├── scripts/
│   └── generate-cert.sh     # Script de geração do certificado
├── output/
│   └── certs/               # Arquivos de certificado (gerado pela pipeline)
├── .gitignore
└── README.md
```

## Arquivos de Saída

| Arquivo | Descrição |
|---------|-----------|
| `certificate.pem` | Certificado do servidor |
| `private-key.pem` | Chave privada (**manter secreta**) |
| `chain.pem` | Certificados intermediários |
| `fullchain.pem` | Certificado + chain (**usar este em servidores web**) |

## Configuração

### Secrets do GitHub (Settings → Secrets → Actions)

| Secret | Descrição |
|--------|-----------|
| `CF_API_TOKEN` | Token da API Cloudflare (permissão: `Zone.Zone:Read`, `Zone.DNS:Edit`) |
| `CF_ZONE_ID` | ID da zona no Cloudflare (Dashboard → Zone Overview) |

### Variables do GitHub (Settings → Secrets → Actions → Variables)

| Variable | Descrição |
|----------|-----------|
| `LE_CERT_DOMAINS` | Domínios separados por vírgula (ex: `example.com,api.example.com`) |
| `LE_CERTBOT_EMAIL` | Email para registro no Let's Encrypt |

## Uso

### Via GitHub Actions (manual)

1. Vá em **Actions → Generate Let's Encrypt Certificate → Run workflow**
2. Preencha os domínios e email
3. O workflow gera o certificado e disponibiliza como **Artifact**
4. Baixe o artifact `letsencrypt-certificate-<run>` para obter os arquivos `.pem`

### Via GitHub Actions (automático)

A pipeline roda a cada 2 meses via cron (`0 3 1 */2 *`), renovando automaticamente.

### Local (desenvolvimento/teste)

```bash
# Requisitos: certbot + python3-certbot-dns-cloudflare
export DOMAINS="example.com,api.example.com"
export CERTBOT_EMAIL="admin@example.com"
export CF_Token="seu-token-aqui"
export CF_Zone_ID="seu-zone-id-aqui"

./scripts/generate-cert.sh
```

Os arquivos serão gerados em `output/certs/`.

## Segurança

- Chaves privadas ficam nos artifacts do GitHub Actions (com retenção de 90 dias)
- O `.gitignore` exclui arquivos `.pem` do commit local
- O workflow faz commit apenas dos certificados no repositório (via bot)
- Nunca exponha o `private-key.pem`
