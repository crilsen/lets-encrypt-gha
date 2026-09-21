# Let's Encrypt Certificate Pipeline

Geração automatizada de certificados Let's Encrypt via GitHub Actions, com validação DNS-01 (Cloudflare) e suporte a múltiplos SANs.

## 🎯 Visão Geral

Este projeto automatiza a geração e renovação de certificados SSL/TLS usando:
- **Let's Encrypt** como autoridade certificadora
- **Cloudflare** para validação DNS-01 (suporta wildcards)
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

## ⚙️ Configuração

### 1. Secrets do GitHub

Acesse **Settings → Secrets and variables → Actions → New repository secret**:

| Secret | Descrição | Como obter |
|--------|-----------|------------|
| `CF_API_TOKEN` | Token da API Cloudflare | Cloudflare Dashboard → My Profile → API Tokens → Create Token |
| `CF_ZONE_ID` | ID da zona no Cloudflare | Cloudflare Dashboard → Zone Overview → Zone ID |

**Permissões do token Cloudflare:**
- `Zone.Zone:Read` - Ler informações da zona
- `Zone.DNS:Edit` - Editar registros DNS (para validação TXT)

### 2. Variables do GitHub

Acesse **Settings → Secrets and variables → Actions → Variables → New repository variable**:

| Variable | Descrição | Exemplo |
|----------|-----------|---------|
| `LE_CERT_DOMAINS` | Domínios separados por vírgula | `example.com,*.example.com,api.example.com` |
| `LE_CERTBOT_EMAIL` | Email para registro no Let's Encrypt | `admin@example.com` |

## 🚀 Uso

### Via GitHub Actions (manual)

1. Acesse **Actions → Generate Let's Encrypt Certificate**
2. Clique em **Run workflow**
3. Preencha:
   - **Domains**: `example.com,*.example.com` (separados por vírgula)
   - **Email**: `seu@email.com`
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
sudo apt-get install -y certbot python3-certbot-dns-cloudflare

# Configurar variáveis de ambiente
export DOMAINS="example.com,*.example.com"
export CERTBOT_EMAIL="admin@example.com"
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

## 🐛 Solução de Problemas

### Erro: "DNS problem: NXDOMAIN looking up TXT"

- Verifique se o token Cloudflare tem permissão `Zone.DNS:Edit`
- Aguarde a propagação DNS (pode levar até 5 minutos)

### Erro: "Too many certificates already issued"

- Let's Encrypt tem limite de 50 certificados por domínio por semana
- Aguarde 7 dias ou use um domínio diferente para teste

### Erro: "Unauthorized"

- Verifique se o token Cloudflare está correto
- Confirme que o Zone ID corresponde ao domínio correto

## 📚 Referências

- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Certbot Documentation](https://certbot.eff.org/instructions)
- [Cloudflare API Documentation](https://developers.cloudflare.com/api/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

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