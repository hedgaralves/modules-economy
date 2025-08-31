terraform {
  backend "s3" {
    bucket         = "<NOME_DO_BUCKET>" # Substitua pelo nome do bucket S3
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "<NOME_DA_TABELA_DYNAMODB>" # Substitua pelo nome da tabela DynamoDB
    encrypt        = true
  }
}
