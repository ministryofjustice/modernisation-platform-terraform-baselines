terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0.1"
}

provider "aws" {
  alias  = "modernisation-platform-eu-west-1"
  region = "eu-west-1"
}