
# terraform-eks-cost-optimized

> Módulo Terraform reutilizável para provisionar clusters Amazon EKS otimizados para custos, com governança FinOps, segurança e automação CI/CD.

---

## Principais Recursos
- EKS com Node Groups Spot e On-Demand (mistura para resiliência e economia)
- Suporte a instâncias Graviton (arm64) para melhor custo-benefício
- Cluster Autoscaler via Helm
- StorageClass padrão gp3
- Tagueamento robusto para rastreio de custos (FinOps)
- Backend remoto seguro (S3 + DynamoDB)
- Pronto para CI/CD com GitHub Actions e OIDC
- Exemplo pronto para ambientes dev/prod

---


## Como Usar e Acionar a Pipeline

### 1. Adicione o módulo ao seu projeto

```hcl
module "eks_cost_optimized" {
	source = "git::https://github.com/sua-org/terraform-eks-cost-optimized.git?ref=v1.0.0"
	eks_name = "eks-dev"
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
