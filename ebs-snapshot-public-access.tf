# ebs-snapshot-public-access.tf

module "ebs-snapshot-public-access-ap-northeast-1" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.ap-northeast-1
  }
}

module "ebs-snapshot-public-access-ap-northeast-2" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.ap-northeast-2
  }
}

module "ebs-snapshot-public-access-ap-south-1" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.ap-south-1
  }
}

module "ebs-snapshot-public-access-ap-southeast-1" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.ap-southeast-1
  }
}

module "ebs-snapshot-public-access-ap-southeast-2" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.ap-southeast-2
  }
}

module "ebs-snapshot-public-access-ca-central-1" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.ca-central-1
  }
}

module "ebs-snapshot-public-access-eu-central-1" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.eu-central-1
  }
}

module "ebs-snapshot-public-access-eu-north-1" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.eu-north-1
  }
}

module "ebs-snapshot-public-access-eu-west-1" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.eu-west-1
  }
}

module "ebs-snapshot-public-access-eu-west-2" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.eu-west-2
  }
}

module "ebs-snapshot-public-access-eu-west-3" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.eu-west-3
  }
}

module "ebs-snapshot-public-access-sa-east-1" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.sa-east-1
  }
}

module "ebs-snapshot-public-access-us-east-1" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.us-east-1
  }
}

module "ebs-snapshot-public-access-us-east-2" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.us-east-2
  }
}

module "ebs-snapshot-public-access-us-west-1" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.us-west-1
  }
}

module "ebs-snapshot-public-access-us-west-2" {
  source = "./modules/ebs-snapshot-public-access"
  providers = {
    aws = aws.us-west-2
  }
}
