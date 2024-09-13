terraform {
  required_providers {
    aws = {
      version = "~> 5.0"
      source  = "hashicorp/aws"
    }
    http = {
      version = "~> 3.0"
      source  = "hashicorp/http"
    }
  }
  required_version = "~> 1.0"
}

provider "aws" {
  alias  = "modernisation-platform-eu-west-1"
  region = "eu-west-1"
}
