## create s3 bucket
resource "aws_s3_bucket" "eks_s3" {
  bucket = "eks-s3-terraform-bucket"

  tags = {
    Name = "statefile_bucket"

  }
}

resource "aws_s3_bucket_versioning" "eks_s3_versioning" {
  bucket = aws_s3_bucket.eks_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}


## create dynamo table
resource "aws_dynamodb_table" "eks_s3_dynamodb-table" {
  name         = "EksTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "eks-s3-dynamodb-table"
  }
}


terraform {
  required_version = "~> 1.9.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49.0"
    }
  }
  backend "s3" {
    bucket         = "eks-s3-terraform-bucket"
    region         = "eu-north-1"
    key            = "eks/terraform.tfstate"
    dynamodb_table = "EksTable"
    encrypt        = true
  }
}

provider "aws" {
  region  = var.aws-region
}
