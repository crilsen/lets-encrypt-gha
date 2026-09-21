# lets-encrypt-gha

Geração automatizada de certificados Let's Encrypt via GitHub Actions, com validação DNS-01 e suporte a múltiplos providers.

## 🎯 Visão Geral

Este projeto automatiza a geração e renovação de certificados SSL/TLS usando:
- **Let's Encrypt** como autoridade certificadora
- **Múltiplos providers de DNS** para validação DNS-01
- **GitHub Actions** para orquestração e agendamento
- **ECDSA (P-256)** para chaves criptográficas (mais rápido que RSA)

## 📁 Estrutura

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

## 📄 Arquivos de Saída

| Arquivo | Descrição | Uso |
|---------|-----------|-----|
| `certificate.pem` | Certificado do servidor | Servidor web |
| `private-key.pem` | Chave privada (**manter secreta**) | Configuração do servidor |
| `chain.pem` | Certificados intermediários | Verificação de cadeia |
| `fullchain.pem` | Certificado + chain (**recomendado**) | Configuração principal |

## 🔌 Providers de DNS Suportados

| Provider | Plugin | Variáveis de Ambiente Necessárias |
|----------|--------|-----------------------------------|
| **Cloudflare** | `python3-certbot-dns-cloudflare` | `CF_Token`, `CF_Zone_ID` |
| **AWS Route53** | `certbot-dns-route53` | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` |
| **Google Cloud** | `certbot-dns-google` | `GOOGLE_CREDENTIALS` (caminho para JSON) |
| **Azure** | `certbot-dns-azure` | `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` |
| **DigitalOcean** | `certbot-dns-digitalocean` | `DO_API_TOKEN` |
| **Linode** | `certbot-dns-linode` | `LINODE_API_TOKEN` |
| **OVH** | `certbot-dns-ovh` | `OVH_APPLICATION_KEY`, `OVH_APPLICATION_SECRET`, `OVH_CONSUMER_KEY` |
| **RFC 2136** | `certbot-dns-rfc2136` | `RFC2136_NAMESERVER`, `RFC2136_CREDENTIALS` |

## ⚙️ Configuração

### 1. Secrets do GitHub

Acesse **Settings → Secrets and variables → Actions → New repository secret**:

#### Cloudflare
| Secret | Descrição | Como obter |
|--------|-----------|------------|
| `CF_API_TOKEN` | Token da API Cloudflare | Cloudflare Dashboard → My Profile → API Tokens → Create Token |
| `CF_ZONE_ID` | ID da zona no Cloudflare | Cloudflare Dashboard → Zone Overview → Zone ID |

**Permissões do token Cloudflare:**
- `Zone.Zone:Read` - Ler informações da zona
- `Zone.DNS:Edit` - Editar registros DNS (para validação TXT)

#### AWS Route53
| Secret | Descrição | Como obter |
|--------|-----------|------------|
| `AWS_ACCESS_KEY_ID` | Access Key ID da AWS | AWS IAM → Users → Security credentials |
| `AWS_SECRET_ACCESS_KEY` | Secret Access Key da AWS | AWS IAM → Users → Security credentials |

**Permissões IAM:**
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

#### Google Cloud DNS
| Secret | Descrição | Como obter |
|--------|-----------|------------|
| `GOOGLE_CREDENTIALS` | JSON das credenciais de serviço | Google Cloud Console → IAM → Service Accounts → Create Key |

**Permissões:**
- `dns.admin` no projeto Google Cloud

#### Azure DNS
| Secret | Descrição | Como obter |
|--------|-----------|------------|
| `AZURE_CLIENT_ID` | Application ID | Azure Portal → App registrations |
| `AZURE_CLIENT_SECRET` | Client secret | Azure Portal → App registrations → Certificates & secrets |
| `AZURE_TENANT_ID` | Tenant ID | Azure Portal → Azure Active Directory |
| `AZURE_SUBSCRIPTION_ID` | Subscription ID | Azure Portal → Subscriptions |

**Permissões:**
- Contributor no resource group do DNS Zone

#### DigitalOcean
| Secret | Descrição | Como obter |
|--------|-----------|------------|
| `DO_API_TOKEN` | Personal Access Token | DigitalOcean API → Tokens → Generate New Token |

**Permissões:**
- `domain` (Read/Write)

#### Linode
| Secret | Descrição | Como obter |
|--------|-----------|------------|
| `LINODE_API_TOKEN` | Personal Access Token | Linode Manager → My Profile → API Tokens |

**Permissões:**
- Read/Write access to Domains

#### OVH
| Secret | Descrição | Como obter |
|--------|-----------|------------|
| `OVH_APPLICATION_KEY` | Application Key | OVH API → API Applications |
| `OVH_APPLICATION_SECRET` | Application Secret | OVH API → API Applications |
| `OVH_CONSUMER_KEY` | Consumer Key | OVH API → API Consumers |

**Permissões:**
- `GET /domain/zone/*`
- `PUT /domain/zone/*`
- `POST /domain/zone/*`

#### RFC 2136
| Secret | Descrição | Como obter |
|--------|-----------|------------|
| `RFC2136_NAMESERVER` | Nameserver do domínio | Seu servidor DNS |
| `RFC2136_CREDENTIALS` | Arquivo de credenciais TSIG | Seu servidor DNS |

### 2. Variables do GitHub

Acesse **Settings → Secrets and variables → Actions → Variables → New repository variable**:

| Variable | Descrição | Exemplo |
|----------|-----------|---------|
| `LE_CERT_DOMAINS` | Domínios separados por vírgula | `example.com,*.example.com,api.example.com` |
| `LE_CERTBOT_EMAIL` | Email para registro no Let's Encrypt | `admin@example.com` |
| `LE_DNS_PROVIDER` | Provider de DNS (opcional, padrão: cloudflare) | `cloudflare` |

## 🚀 Uso

### Via GitHub Actions (manual)

1. Acesse **Actions → Generate Let's Encrypt Certificate**
2. Clique em **Run workflow**
3. Preencha:
   - **Domains**: `example.com,*.example.com` (separados por vírgula)
   - **Email**: `seu@email.com`
   - **DNS Provider**: Selecione o provider (padrão: cloudflare)
4. Clique em **Run workflow**
5. Aguarde a conclusão e baixe o artifact

### Via GitHub Actions (automático)

A pipeline executa automaticamente a cada 2 meses:
```yaml
cron: "0 3 1 */2 *"  # Dia 1 de cada 2º mês às 03:00 UTC
```

### Local (desenvolvimento/teste)

```bash
# Instalar dependências (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y certbot python3-pip

# Instalar plugin do provider (exemplo: Cloudflare)
pip3 install certbot-dns-cloudflare

# Configurar variáveis de ambiente
export DOMAINS="example.com,*.example.com"
export CERTBOT_EMAIL="admin@example.com"
export DNS_PROVIDER="cloudflare"
export CF_Token="seu-token-aqui"
export CF_Zone_ID="seu-zone-id-aqui"

# Executar script
chmod +x scripts/generate-cert.sh
./scripts/generate-cert.sh
```

Os arquivos serão gerados em `output/certs/`.

## 🔒 Segurança

- ✅ Chaves privadas ficam nos artifacts do GitHub Actions (retenção de 90 dias)
- ✅ O `.gitignore` exclui arquivos `.pem` do commit local
- ✅ O workflow faz commit apenas dos certificados (via bot automático)
- ✅ Nunca exponha o `private-key.pem`
- ✅ Use variáveis de ambiente ou GitHub Secrets para credenciais

## 🔄 Renovação

- **Frequência**: A cada 60 dias (certificados validam por 90 dias)
- **Agenda**: Dia 1 de cada 2º mês às 03:00 UTC
- ** automático**: Workflow faz commit dos novos certificados
- **Manual**: Execute o workflow sempre que necessário

## 🛠️ Personalização

### Adicionar novos domínios

Edite a variável `LE_CERT_DOMAINS` no GitHub:
```
example.com,*.example.com,api.example.com,app.example.com
```

### Alterar tipo de chave

Para usar RSA em vez de ECDSA, edite `scripts/generate-cert.sh`:
```bash
# Alterar de:
--key-type ecdsa \
--elliptic-curve secp256r1 \

# Para:
--key-type rsa \
--rsa-key-size 4096 \
```

### Alterar agendamento

Edite o cron no workflow `.github/workflows/certificate.yml`:
```yaml
schedule:
  # Exemplo: todo dia 1º de mês às 03:00 UTC
  cron: "0 3 1 * *"
```

### Alterar provider de DNS

Edite a variável `LE_DNS_PROVIDER` no GitHub ou selecione no workflow manual.

## 🐛 Solução de Problemas

### Erro: "DNS problem: NXDOMAIN looking up TXT"

- Verifique se o token do provider tem permissão para editar registros DNS
- Aguarde a propagação DNS (pode levar até 5 minutos)

### Erro: "Too many certificates already issued"

- Let's Encrypt tem limite de 50 certificados por domínio por semana
- Aguarde 7 dias ou use um domínio diferente para teste

### Erro: "Unauthorized"

- Verifique se as credenciais do provider estão corretas
- Confirme que as permissões estão configuradas corretamente

### Erro: "Plugin not installed"

- O plugin do provider não está instalado
- Execute: `pip3 install certbot-dns-<provider>`

## 📚 Referências

- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Certbot Documentation](https://certbot.eff.org/instructions)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Certbot DNS Plugins](https://certbot.eff.org/docs/using.html#dns-plugins)

## 📄 Licença

MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-funcionalidade`)
3. Faça commit (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

---

**⚠️ Importante**: Nunca compartilhe seus tokens de API ou chaves privadas. Use sempre GitHub Secrets para armazenar credenciais sensíveis.