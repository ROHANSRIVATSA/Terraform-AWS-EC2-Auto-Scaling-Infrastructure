terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment below for remote state management with S3 backend
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "asg-infrastructure/terraform.tfstate"
  #   region         = "us-west-2"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

provider "aws" {
  region = var.AWS_REGION

  default_tags {
    tags = {
      Project     = "Terraform-ASG-Infrastructure"
      Environment = "Development"
      ManagedBy   = "Terraform"
    }
  }
}