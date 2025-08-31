
###############################
# Outputs do Módulo EKS FinOps
###############################

output "eks_cluster_id" {
	description = "ID do cluster EKS."
	value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
	description = "Endpoint do cluster EKS."
	value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
	description = "Versão do Kubernetes no cluster."
	value       = module.eks.cluster_version
}

output "eks_oidc_issuer_url" {
	description = "URL do OIDC provider do cluster (para IRSA)."
	value       = module.eks.oidc_provider
}

output "eks_node_group_spot_arn" {
	description = "ARN do Node Group Spot."
	value       = try(module.eks.eks_managed_node_groups["spot"].node_group_arn, null)
}

output "eks_node_group_ondemand_arn" {
	description = "ARN do Node Group On-Demand."
	value       = try(module.eks.eks_managed_node_groups["on_demand"].node_group_arn, null)
}

output "vpc_id" {
	description = "ID da VPC criada ou utilizada."
	value       = module.vpc.vpc_id
}

output "private_subnets" {
	description = "IDs das sub-redes privadas."
	value       = module.vpc.private_subnets
}

output "tags_utilizadas" {
	description = "Tags aplicadas para rastreio de custos."
	value       = local.tags
}
