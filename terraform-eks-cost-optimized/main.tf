# -----------------------------
# Módulo EKS Otimizado para Custos
# -----------------------------

# 1. VPC (pode ser criada ou reutilizada)
module "vpc" {
	source  = "terraform-aws-modules/vpc/aws"
	version = "5.1.0"
	name = var.vpc_name
	cidr = var.vpc_cidr
	azs             = var.vpc_azs
	private_subnets = var.vpc_private_subnets
	public_subnets  = var.vpc_public_subnets
	enable_nat_gateway = var.vpc_enable_nat_gateway
	single_nat_gateway = var.vpc_single_nat_gateway
	tags = local.tags
}

# 2. IAM Roles para EKS e Node Groups
# module "eks_iam" {
#   source  = "terraform-aws-modules/iam/aws//modules/eks"
#   version = "5.35.0"
# }

# 3. Cluster EKS
module "eks" {
	source  = "terraform-aws-modules/eks/aws"
	version = "~> 20.0"

	cluster_name    = var.eks_name
	cluster_version = var.eks_version
	vpc_id          = module.vpc.vpc_id
	subnet_ids      = module.vpc.private_subnets
	# Se usar subnets dedicadas para control plane, adicione:
	# control_plane_subnet_ids = [ ... ]

	cluster_endpoint_public_access = true

	cluster_addons = {
		coredns = {
			most_recent = true
		}
		kube-proxy = {
			most_recent = true
		}
		vpc-cni = {
			most_recent = true
		}
	}

	eks_managed_node_group_defaults = {
		instance_types = ["t3.large", "t3a.large", "m5.large", "m6i.large"]
	}

	eks_managed_node_groups = {
		spot = {
			min_size     = var.spot_min_size
			max_size     = var.spot_max_size
			desired_size = var.spot_desired_size
			instance_types = var.spot_instance_types
			capacity_type  = "SPOT"
			labels = {
				lifecycle = "Ec2Spot"
			}
			tags = merge(local.tags, { "k8s.io/lifecycle" = "Ec2Spot" })
		}
		on_demand = {
			min_size     = var.ondemand_min_size
			max_size     = var.ondemand_max_size
			desired_size = var.ondemand_desired_size
			instance_types = var.ondemand_instance_types
			capacity_type  = "ON_DEMAND"
			labels = {
				lifecycle = "OnDemand"
			}
			tags = merge(local.tags, { "k8s.io/lifecycle" = "OnDemand" })
		}
	}

	enable_cluster_creator_admin_permissions = true

	access_entries = {
		example = {
			kubernetes_groups = []
			principal_arn     = "arn:aws:iam::123456789012:role/something"
			policy_associations = {
				example = {
					policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
					access_scope = {
						namespaces = ["default"]
						type       = "namespace"
					}
				}
			}
		}
	}

	cluster_tags = local.tags
	tags         = local.tags
	node_security_group_tags = local.tags
}

# 4. Cluster Autoscaler via Helm
resource "helm_release" "cluster_autoscaler" {
	name       = "cluster-autoscaler"
	repository = "https://kubernetes.github.io/autoscaler"
	chart      = "cluster-autoscaler"
	version    = var.cluster_autoscaler_helm_version
	namespace  = "kube-system"
	create_namespace = false
	values = [
		<<-EOT
		autoDiscovery:
			clusterName: ${var.eks_name}
		awsRegion: ${var.aws_region}
		rbac:
			create: true
		extraArgs:
			skip-nodes-with-local-storage: false
			balance-similar-node-groups: true
		EOT
	]
	depends_on = [module.eks]
}

# 5. StorageClass padrão gp3
resource "kubernetes_storage_class" "gp3" {
	metadata {
		name = "gp3"
		annotations = {
			"storageclass.kubernetes.io/is-default-class" = "true"
		}
	}
	storage_provisioner = "ebs.csi.aws.com"
	parameters = {
		type = "gp3"
	}
	reclaim_policy = "Delete"
	volume_binding_mode = "WaitForFirstConsumer"
}

# 6. Outputs e orientações FinOps
# - Requests/Limits e HPA devem ser aplicados nas aplicações (ver README)
# - Tags obrigatórias para rastreio de custos
# - Recomenda-se uso de Savings Plans para produção estável

# 7. Permissões para GitHub Actions
resource "aws_iam_role" "github_actions" {
	name = "GitHubActionsRole"
	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
			{
				Effect = "Allow"
				Principal = {
					Federated = "arn:aws:iam::<ID_DA_CONTA>:oidc-provider/token.actions.githubusercontent.com"
				}
				Action = "sts:AssumeRoleWithWebIdentity"
				Condition = {
					StringEquals = {
						"token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
						"token.actions.githubusercontent.com:sub" = "repo:<SEU_ORG>/<SEU_REPO>:ref:refs/heads/main"
					}
				}
			}
		]
	})
}

locals {
  tags = {
    "Project"     = contains(keys(var.tags), "Project")     ? var.tags["Project"]     : "eks-cost-optimized"
    "Environment" = contains(keys(var.tags), "Environment") ? var.tags["Environment"] : "dev"
    "Owner"       = contains(keys(var.tags), "Owner")       ? var.tags["Owner"]       : "team"
    "CostCenter"  = contains(keys(var.tags), "CostCenter")  ? var.tags["CostCenter"]  : "0000"
  }
}
