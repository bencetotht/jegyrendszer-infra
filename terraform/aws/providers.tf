terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "bnbdevelopment-tfstate-bucket"
    key = "aws/terraform.tfstate"
    region = "eu-north-1"
    encrypt = true
  }
}

variable "aws_access_key" {
  type = string
  sensitive = true
}

variable "aws_secret_key" {
  type = string
  sensitive = true
}

provider "aws" {
  region = "eu-north-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}