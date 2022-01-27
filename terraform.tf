terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48.0"
    }
  }
  required_version = "~> 1.0"
  backend "s3" {
    bucket = "yousician-dev-terraform-bucket"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = var.aws_primary_region

}

provider "aws" {
  alias  = "secondary"
  region = var.aws_secondary_region
}
