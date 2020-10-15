module "securityhub-ap-northeast-1" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.ap-northeast-1
  }
}

module "securityhub-ap-northeast-2" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.ap-northeast-2
  }
}

module "securityhub-ap-south-1" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.ap-south-1
  }
}

module "securityhub-ap-southeast-1" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.ap-southeast-1
  }
}

module "securityhub-ap-southeast-2" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.ap-southeast-2
  }
}

module "securityhub-ca-central-1" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.ca-central-1
  }
}

module "securityhub-eu-central-1" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.eu-central-1
  }
}

module "securityhub-eu-north-1" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.eu-north-1
  }
}

module "securityhub-eu-west-1" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.eu-west-1
  }
}

module "securityhub-eu-west-2" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.eu-west-2
  }
}

module "securityhub-eu-west-3" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.eu-west-3
  }
}

module "securityhub-sa-east-1" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.sa-east-1
  }
}

module "securityhub-us-east-1" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.us-east-1
  }
}

module "securityhub-us-east-2" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.us-east-2
  }
}

module "securityhub-us-west-1" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.us-west-1
  }
}

module "securityhub-us-west-2" {
  source = "./modules/securityhub"
  providers = {
    aws = aws.us-west-2
  }
}
