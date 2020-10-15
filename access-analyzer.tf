module "access-analyzer-ap-northeast-1" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.ap-northeast-1
  }
  tags = var.tags
}

module "access-analyzer-ap-northeast-2" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.ap-northeast-2
  }
  tags = var.tags
}

module "access-analyzer-ap-south-1" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.ap-south-1
  }
  tags = var.tags
}

module "access-analyzer-ap-southeast-1" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.ap-southeast-1
  }
  tags = var.tags
}

module "access-analyzer-ap-southeast-2" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.ap-southeast-2
  }
  tags = var.tags
}

module "access-analyzer-ca-central-1" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.ca-central-1
  }
  tags = var.tags
}

module "access-analyzer-eu-central-1" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.eu-central-1
  }
  tags = var.tags
}

module "access-analyzer-eu-north-1" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.eu-north-1
  }
  tags = var.tags
}

module "access-analyzer-eu-west-1" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.eu-west-1
  }
  tags = var.tags
}

module "access-analyzer-eu-west-2" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.eu-west-2
  }
  tags = var.tags
}

module "access-analyzer-eu-west-3" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.eu-west-3
  }
  tags = var.tags
}

module "access-analyzer-sa-east-1" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.sa-east-1
  }
  tags = var.tags
}

module "access-analyzer-us-east-1" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.us-east-1
  }
  tags = var.tags
}

module "access-analyzer-us-east-2" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.us-east-2
  }
  tags = var.tags
}

module "access-analyzer-us-west-1" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.us-west-1
  }
  tags = var.tags
}

module "access-analyzer-us-west-2" {
  source = "./modules/access-analyzer"
  providers = {
    aws = aws.us-west-2
  }
  tags = var.tags
}
