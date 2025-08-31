# terraform-eks-cost-optimized

> Módulo Terraform para EKS otimizado para custos, CI/CD seguro, FinOps e governança IaC.

---

<p align="center">
  <img src="https://img.shields.io/badge/IaC-Terraform-blueviolet?style=for-the-badge" />
  <img src="https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/FinOps-Ready-brightgreen?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Security-Trivy%20%26%20OIDC-orange?style=for-the-badge" />
</p>

---

## ✨ Sumário

- [Visão Geral](#visão-geral)
- [Diferenciais](#diferenciais)
- [Como Usar e Automação](#como-usar-e-automação)
- [Pipeline CI/CD](#pipeline-cicd)
- [Segurança & FinOps](#segurança--finops)
- [Troubleshooting](#troubleshooting)
- [Exemplos de Uso](#exemplos-de-uso)
- [Contribuição](#contribuição)
- [Licença](#licença)

---

## 👀 Visão Geral

Cluster Amazon EKS pronto para produção, com práticas modernas de FinOps, automação CI/CD, segurança e rastreabilidade total.

---

## 🏆 Diferenciais

| 🚩 | Destaque |
|---|---|
| 💾 | **IaC 100%:** Provisionamento versionado, auditável e reproduzível |
| 🤖 | **CI/CD Completo:** GitHub Actions, Trivy, OIDC, deploy automatizado, Slack |
| 🔒 | **Segurança:** Backend remoto, OIDC, RBAC, endpoint restrito, scan IaC, tags |
| 💸 | **FinOps:** Node Groups Spot/On-Demand, tags de custo, Savings Plans, auto-destroy |

---

## 🚦 Como Usar e Automação

### ⏰ Automação Inteligente (GitHub Actions)

- O cluster EKS é **criado automaticamente todos os dias às 07:00 UTC**.
- Todos os recursos são **destruídos automaticamente às 19:00 UTC** para economia de custos.
- Você pode acionar manualmente a criação ou destruição a qualquer momento pelo GitHub Actions.

> **Dica:** Ajuste o horário no workflow (`.github/workflows/terraform-apply.yml` e `terraform-destroy.yml`) conforme seu fuso horário, se necessário.

### 1️⃣ Adicione o módulo ao seu projeto
```hcl
module "eks_cost_optimized" {
  source     = "git::https://github.com/sua-org/terraform-eks-cost-optimized.git?ref=v1.0.0"
  eks_name   = "eks-lab"
  aws_region = "us-east-1"
  # ...outras variáveis...
  tags = {
    Project     = "economy-platform"
    Environment = "dev"
    Owner       = "squad-devops"
    CostCenter  = "1234"
  }
}
```

### 2️⃣ Configure o backend remoto
Edite `backend.tf` com bucket S3 e tabela DynamoDB para state lock seguro.

### 3️⃣ Execute localmente
```sh
terraform init
terraform plan -var-file=usage-examples/eks-dev.tf
terraform apply -var-file=usage-examples/eks-dev.tf
```

---

## ⚙️ Pipeline CI/CD

- Trivy roda **antes** do apply, bloqueando deploys inseguros
- Apply dividido: primeiro EKS, depois recursos K8s/Helm
- Kubeconfig atualizado automaticamente
- Notificações de status no Slack

#### 🔑 Secrets obrigatórios:
- `AWS_ROLE_OIDC`: ARN do role IAM com trust OIDC
- `SLACK_WEBHOOK_URL`: Webhook do Slack

#### 🛡️ Exemplo de Trust Policy OIDC:
```json
{
  "Effect": "Allow",
  "Principal": {
    "Federated": "arn:aws:iam::<ID_DA_CONTA>:oidc-provider/token.actions.githubusercontent.com"
  },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
    "StringEquals": {
      "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
    },
    "StringLike": {
      "token.actions.githubusercontent.com:sub": "repo:<SEU_ORG>/<SEU_REPO>:ref:refs/heads/main"
    }
  }
}
```

---

## 🛡️ Segurança & 💰 FinOps

> **Dicas rápidas:**

- 🔍 **Scan Trivy:** Todo commit é escaneado antes do apply. Deploys inseguros são bloqueados.
- 🌐 **Endpoint EKS:** Por padrão, público só para pipeline. Restrinja para IP fixo em produção.
- 🏷️ **Tags obrigatórias:** FinOps, rastreio e governança.
- ☁️ **Backend remoto:** Nunca use state local em produção.
- 🔑 **OIDC:** Use roles dedicadas para CI/CD, nunca chaves fixas.
- 🛡️ **RBAC:** Use grupos e roles para acesso granular ao cluster.
- 🔥 **Destruição automatizada:** Programe auto-destroy para ambientes temporários.

---

## 🧰 Troubleshooting

| Erro | Solução |
|------|---------|
| OIDC | Revise trust policy e secrets |
| Acesso ao cluster | Verifique endpoint, kubeconfig e permissões |
| Trivy | Corrija findings críticos antes do apply |
| Timeout no apply | Certifique-se que o endpoint do EKS está acessível para o runner |

---

## 📚 Exemplos de Uso

Explore exemplos práticos para diferentes cenários:

- [`usage-examples/eks-dev.tf`](terraform-eks-cost-optimized/usage-examples/eks-dev.tf): Exemplo de cluster EKS para ambiente de desenvolvimento.
- [`examples/eks-dev.tf`](terraform-eks-cost-optimized/examples/eks-dev.tf): Outro exemplo de uso para referência.

Sinta-se à vontade para criar novos arquivos de exemplo para ambientes como produção, staging, etc. Basta seguir o padrão dos arquivos acima!

---

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature/fix
3. Abra um Pull Request
4. Siga as boas práticas de código, segurança e FinOps

Sugestão: adicione testes automatizados (Terratest, Checkov, Trivy) para garantir qualidade.

---

## 📄 Licença

MIT. Sinta-se livre para usar, adaptar e contribuir!
