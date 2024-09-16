terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [  aws.eu-west-2,aws.eu-west-1]
    }
  }
  required_version = ">= 1.0.1"
}