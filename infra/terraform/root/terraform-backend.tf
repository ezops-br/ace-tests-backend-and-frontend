terraform {
  backend "s3" {
    bucket         = "ace-tests-frontend-tfstate-af88104b"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ace-tests-frontend-tfstate-locks-af88104b"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
