terraform {
  backend "s3" {
    bucket         = "eks-tfstate-lab-hedgaralves" # Substitua pelo nome do bucket S3
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "eks-tfstate-lock" # Substitua pelo nome da tabela DynamoDB
    encrypt        = true
  }
}
