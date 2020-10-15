module "guardduty-ap-northeast-1" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.ap-northeast-1
  }
  tags = var.tags
}

module "guardduty-ap-northeast-2" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.ap-northeast-2
  }
  tags = var.tags
}

module "guardduty-ap-south-1" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.ap-south-1
  }
  tags = var.tags
}

module "guardduty-ap-southeast-1" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.ap-southeast-1
  }
  tags = var.tags
}

module "guardduty-ap-southeast-2" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.ap-southeast-2
  }
  tags = var.tags
}

module "guardduty-ca-central-1" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.ca-central-1
  }
  tags = var.tags
}

module "guardduty-eu-central-1" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.eu-central-1
  }
  tags = var.tags
}

module "guardduty-eu-north-1" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.eu-north-1
  }
  tags = var.tags
}

module "guardduty-eu-west-1" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.eu-west-1
  }
  tags = var.tags
}

module "guardduty-eu-west-2" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.eu-west-2
  }
  tags = var.tags
}

module "guardduty-eu-west-3" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.eu-west-3
  }
  tags = var.tags
}

module "guardduty-sa-east-1" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.sa-east-1
  }
  tags = var.tags
}

module "guardduty-us-east-1" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.us-east-1
  }
  tags = var.tags
}

module "guardduty-us-east-2" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.us-east-2
  }
  tags = var.tags
}

module "guardduty-us-west-1" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.us-west-1
  }
  tags = var.tags
}

module "guardduty-us-west-2" {
  source = "./modules/guardduty"
  providers = {
    aws = aws.us-west-2
  }
  tags = var.tags
}
