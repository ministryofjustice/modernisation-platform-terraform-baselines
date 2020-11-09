module "backup-ap-northeast-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.ap-northeast-1
  }
  tags = var.tags
}

module "backup-ap-northeast-2" {
  source = "./modules/backup"
  providers = {
    aws = aws.ap-northeast-2
  }
  tags = var.tags
}

module "backup-ap-south-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.ap-south-1
  }
  tags = var.tags
}

module "backup-ap-southeast-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.ap-southeast-1
  }
  tags = var.tags
}

module "backup-ap-southeast-2" {
  source = "./modules/backup"
  providers = {
    aws = aws.ap-southeast-2
  }
  tags = var.tags
}

module "backup-ca-central-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.ca-central-1
  }
  tags = var.tags
}

module "backup-eu-central-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.eu-central-1
  }
  tags = var.tags
}

module "backup-eu-north-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.eu-north-1
  }
  tags = var.tags
}

module "backup-eu-west-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.eu-west-1
  }
  tags = var.tags
}

module "backup-eu-west-2" {
  source = "./modules/backup"
  providers = {
    aws = aws.eu-west-2
  }
  tags = var.tags
}

module "backup-eu-west-3" {
  source = "./modules/backup"
  providers = {
    aws = aws.eu-west-3
  }
  tags = var.tags
}

module "backup-sa-east-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.sa-east-1
  }
  tags = var.tags
}

module "backup-us-east-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.us-east-1
  }
  tags = var.tags
}

module "backup-us-east-2" {
  source = "./modules/backup"
  providers = {
    aws = aws.us-east-2
  }
  tags = var.tags
}

module "backup-us-west-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.us-west-1
  }
  tags = var.tags
}

module "backup-us-west-2" {
  source = "./modules/backup"
  providers = {
    aws = aws.us-west-2
  }
  tags = var.tags
}
