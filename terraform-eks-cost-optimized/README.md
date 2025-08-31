

# terraform-eks-cost-optimized

> Módulo Terraform para EKS otimizado para custos, CI/CD seguro e governança de infraestrutura como código.

---

## Visão Geral
Este módulo entrega um cluster Amazon EKS pronto para produção, com práticas modernas de FinOps, automação CI/CD, segurança e rastreabilidade total.

### Principais Diferenciais
- **Infraestrutura como Código (IaC):** Todo o provisionamento é versionado, auditável e reproduzível.
- **CI/CD Completo:** Pipeline GitHub Actions com validação Trivy, OIDC seguro, deploy automatizado e notificação Slack.
- **Segurança:** Backend remoto seguro, OIDC, RBAC, restrição de endpoint, scan de IaC, tags obrigatórias e exemplos de políticas.
- **FinOps:** Node Groups Spot/On-Demand, tags para rastreio de custos, exemplos de Savings Plans e destruição automatizada.

---

## Como Usar

### 1. Adicione o módulo ao seu projeto
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

### 2. Configure o backend remoto
Edite `backend.tf` com o bucket S3 e tabela DynamoDB para state lock seguro.

### 3. Execute localmente
```sh
terraform init
terraform plan -var-file=usage-examples/eks-dev.tf
terraform apply -var-file=usage-examples/eks-dev.tf
```

### 4. Pipeline CI/CD (GitHub Actions)
- O Trivy roda ANTES do apply, bloqueando deploys inseguros.
- O apply é dividido: primeiro só EKS, depois recursos Kubernetes/Helm.
- O kubeconfig é atualizado automaticamente.
- Notificações de status são enviadas para o Slack.

#### Secrets obrigatórios:
- `AWS_ROLE_OIDC`: ARN do role IAM com trust OIDC
- `SLACK_WEBHOOK_URL`: Webhook do Slack

#### Exemplo de Trust Policy OIDC:
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

## Segurança e Boas Práticas

- **Scan Trivy:** Todo commit é escaneado antes do apply. Deploys inseguros são bloqueados.
- **Endpoint EKS:** Por padrão, público apenas para o pipeline. Restrinja para IP fixo em produção.
- **Tags obrigatórias:** FinOps, rastreio e governança.
- **Backend remoto:** Nunca use state local em produção.
- **OIDC:** Use roles dedicadas para CI/CD, nunca chaves fixas.
- **RBAC:** Use grupos e roles para acesso granular ao cluster.
- **Restrinja egress/ingress:** Ajuste SGs para o mínimo necessário.
- **Destruição automatizada:** Programe auto-destroy para ambientes temporários.

---

## Troubleshooting

- **Erro de OIDC:** Revise trust policy e secrets.
- **Erro de acesso ao cluster:** Verifique endpoint, kubeconfig e permissões.
- **Erro Trivy:** Corrija findings críticos antes do apply.
- **Timeout no apply:** Certifique-se que o endpoint do EKS está acessível para o runner.

---

## Exemplos
Veja exemplos completos em `usage-examples/eks-dev.tf`.

---

## Contribua
1. Fork o projeto
2. Crie uma branch
3. Abra um Pull Request
4. Siga boas práticas de código, segurança e FinOps

Sugestão: adicione testes automatizados (Terratest, Checkov, Trivy).

---

## Licença
MIT. Use, adapte e contribua!

---


## Como Usar e Acionar a Pipeline

### 1. Adicione o módulo ao seu projeto

```hcl
module "eks_cost_optimized" {
	source = "git::https://github.com/sua-org/terraform-eks-cost-optimized.git?ref=v1.0.0"
		eks_name = "eks-lab"
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

### 2. Configure o backend remoto

Edite `backend.tf` com o nome do bucket S3 e tabela DynamoDB criados na AWS.

### 3. Execute localmente

```sh
terraform init
terraform plan -var-file=usage-examples/eks-dev.tf
terraform apply -var-file=usage-examples/eks-dev.tf
```

### 4. Acione a pipeline do GitHub Actions

- Faça um commit e push na branch `main`:
	```sh
	git add .
	git commit -m "chore: trigger pipeline"
	git push origin main
	```
- O workflow será executado automaticamente em **Actions**.
- Acompanhe logs e alertas no Slack (se configurado).

#### Configure os secrets no GitHub:
- `AWS_ROLE_OIDC`: ARN do role IAM com trust OIDC
- `SLACK_WEBHOOK_URL`: Webhook do Slack
- `APPROVERS`: Usuários autorizados para aprovação manual (se necessário)

#### Exemplo de Trust Policy para OIDC (IAM Role na AWS):
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

#### Dicas e Troubleshooting
- Se o workflow não rodar, faça um novo commit e push.
- Se aparecer erro de OIDC, revise a trust policy e o secret no GitHub.
- Se precisar acionar a pipeline manualmente, altere qualquer arquivo e faça push.

---

## Boas Práticas FinOps
- Sempre revise os tipos de instância e estratégias Spot/On-Demand
- Utilize tags para rastreio de custos (Cost Explorer)
- Ajuste requests/limits dos pods e use HPA
- Programe destruição de ambientes não produtivos fora do horário
- Use Savings Plans para workloads estáveis

---

## Exemplos

Veja exemplos completos em `examples/eks-dev.tf` e crie outros conforme seu ambiente.

---

## Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature/fix
3. Abra um Pull Request
4. Siga as boas práticas de código e FinOps

Sugestão: adicione testes automatizados (Terratest, Checkov) para garantir qualidade.

---

## Licença

MIT. Sinta-se livre para usar e contribuir!
