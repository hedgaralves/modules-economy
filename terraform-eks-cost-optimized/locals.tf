
###############################
# Locals para Tagueamento FinOps
###############################

locals {
	tags = merge({
		"Project"     = contains(keys(var.tags), "Project")     ? var.tags["Project"]     : "eks-cost-optimized"
		"Environment" = contains(keys(var.tags), "Environment") ? var.tags["Environment"] : "dev"
		"Owner"       = contains(keys(var.tags), "Owner")       ? var.tags["Owner"]       : "team"
		"CostCenter"  = contains(keys(var.tags), "CostCenter")  ? var.tags["CostCenter"]  : "0000"
		"ManagedBy"   = "Terraform"
		"ProvisionedBy" = "GitHubActions"
	}, var.tags)
}
