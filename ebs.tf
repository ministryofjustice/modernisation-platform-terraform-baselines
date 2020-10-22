module "ebs-ap-northeast-1" {
  source = "./modules/ebs"
  providers = {
    aws = aws.ap-northeast-1
  }
}

module "ebs-ap-northeast-2" {
  source = "./modules/ebs"
  providers = {
    aws = aws.ap-northeast-2
  }
}

module "ebs-ap-south-1" {
  source = "./modules/ebs"
  providers = {
    aws = aws.ap-south-1
  }
}

module "ebs-ap-southeast-1" {
  source = "./modules/ebs"
  providers = {
    aws = aws.ap-southeast-1
  }
}

module "ebs-ap-southeast-2" {
  source = "./modules/ebs"
  providers = {
    aws = aws.ap-southeast-2
  }
}

module "ebs-ca-central-1" {
  source = "./modules/ebs"
  providers = {
    aws = aws.ca-central-1
  }
}

module "ebs-eu-central-1" {
  source = "./modules/ebs"
  providers = {
    aws = aws.eu-central-1
  }
}

module "ebs-eu-north-1" {
  source = "./modules/ebs"
  providers = {
    aws = aws.eu-north-1
  }
}

module "ebs-eu-west-1" {
  source = "./modules/ebs"
  providers = {
    aws = aws.eu-west-1
  }
}

module "ebs-eu-west-2" {
  source = "./modules/ebs"
  providers = {
    aws = aws.eu-west-2
  }
}

module "ebs-eu-west-3" {
  source = "./modules/ebs"
  providers = {
    aws = aws.eu-west-3
  }
}

module "ebs-sa-east-1" {
  source = "./modules/ebs"
  providers = {
    aws = aws.sa-east-1
  }
}

module "ebs-us-east-1" {
  source = "./modules/ebs"
  providers = {
    aws = aws.us-east-1
  }
}

module "ebs-us-east-2" {
  source = "./modules/ebs"
  providers = {
    aws = aws.us-east-2
  }
}

module "ebs-us-west-1" {
  source = "./modules/ebs"
  providers = {
    aws = aws.us-west-1
  }
}

module "ebs-us-west-2" {
  source = "./modules/ebs"
  providers = {
    aws = aws.us-west-2
  }
}
