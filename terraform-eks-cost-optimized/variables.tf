
###############################
# Variáveis do Módulo EKS FinOps
###############################

variable "aws_region" {
	description = "Região AWS onde o cluster será provisionado."
	type        = string
	default     = "us-east-1"
}

variable "eks_name" {
	description = "Nome do cluster EKS."
	type        = string
}

variable "eks_version" {
	description = "Versão do Kubernetes no EKS."
	type        = string
	default     = "1.29"
}

# VPC
variable "vpc_name" {
	description = "Nome da VPC."
	type        = string
	default     = "eks-vpc"
}
variable "vpc_cidr" {
	description = "CIDR da VPC."
	type        = string
	default     = "10.0.0.0/16"
}
variable "vpc_azs" {
	description = "Lista de zonas de disponibilidade."
	type        = list(string)
	default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
variable "vpc_private_subnets" {
	description = "Sub-redes privadas."
	type        = list(string)
	default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "vpc_public_subnets" {
	description = "Sub-redes públicas."
	type        = list(string)
	default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
variable "vpc_enable_nat_gateway" {
	description = "Habilita NAT Gateway."
	type        = bool
	default     = true
}
variable "vpc_single_nat_gateway" {
	description = "Usa apenas um NAT Gateway para economia."
	type        = bool
	default     = true
}

# Node Groups Spot
variable "spot_instance_types" {
	description = "Tipos de instância para Node Group Spot (ex: [\"t4g.medium\", \"m6g.large\"])."
	type        = list(string)
	default     = ["t4g.medium", "m6g.large"]
}
variable "spot_desired_size" {
	description = "Tamanho desejado do Node Group Spot."
	type        = number
	default     = 1
}
variable "spot_min_size" {
	description = "Tamanho mínimo do Node Group Spot."
	type        = number
	default     = 0
}
variable "spot_max_size" {
	description = "Tamanho máximo do Node Group Spot."
	type        = number
	default     = 3
}

# Node Groups On-Demand
variable "ondemand_instance_types" {
	description = "Tipos de instância para Node Group On-Demand."
	type        = list(string)
	default     = ["t4g.medium"]
}
variable "ondemand_desired_size" {
	description = "Tamanho desejado do Node Group On-Demand."
	type        = number
	default     = 1
}
variable "ondemand_min_size" {
	description = "Tamanho mínimo do Node Group On-Demand."
	type        = number
	default     = 1
}
variable "ondemand_max_size" {
	description = "Tamanho máximo do Node Group On-Demand."
	type        = number
	default     = 2
}

# Cluster Autoscaler
variable "cluster_autoscaler_helm_version" {
	description = "Versão do Helm Chart do Cluster Autoscaler."
	type        = string
	default     = "9.37.0"
}

# Tags FinOps
variable "tags" {
	description = "Tags obrigatórias para rastreio de custos (projeto, time, ambiente, owner, etc)."
	type        = map(string)
	default     = {}
}
