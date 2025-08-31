# Exemplo de uso do módulo EKS otimizado para custos

module "eks_cost_optimized" {
  source = "../"

  aws_region = "us-east-1"
  eks_name   = "eks-lab"
  eks_version = "1.29"

  vpc_name = "eks-vpc-lab"
  vpc_cidr = "10.10.0.0/16"
  vpc_azs  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  vpc_public_subnets  = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]

  spot_instance_types = ["t4g.medium", "m6g.large"]
  spot_desired_size   = 1
  spot_min_size       = 0
  spot_max_size       = 2

  ondemand_instance_types = ["t4g.medium"]
  ondemand_desired_size   = 1
  ondemand_min_size       = 1
  ondemand_max_size       = 2

  cluster_autoscaler_helm_version = "9.37.0"

  tags = {
    Project     = "economy-platform"
    Environment = "lab"
    Owner       = "squad-devops"
    CostCenter  = "1234"
  }
}
