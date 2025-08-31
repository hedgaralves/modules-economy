
###############################
# Locals para Tagueamento FinOps
###############################

locals {
	tags = merge({
		"Project"     = var.tags["Project"]     != null ? var.tags["Project"]     : "eks-cost-optimized"
		"Environment" = var.tags["Environment"] != null ? var.tags["Environment"] : "dev"
		"Owner"       = var.tags["Owner"]       != null ? var.tags["Owner"]       : "team"
		"CostCenter"  = var.tags["CostCenter"]  != null ? var.tags["CostCenter"]  : "0000"
		"ManagedBy"   = "Terraform"
		"ProvisionedBy" = "GitHubActions"
	}, var.tags)
}
