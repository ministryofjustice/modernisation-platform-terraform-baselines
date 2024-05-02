module "imdsv2-ap-northeast-1" {
  for_each = contains(var.enabled_imdsv2_regions, "ap-northeast-1") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.ap-northeast-1
  }
}

module "imdsv2-ap-northeast-2" {
  for_each = contains(var.enabled_imdsv2_regions, "ap-northeast-2") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.ap-northeast-2
  }
}

module "imdsv2-ap-south-1" {
  for_each = contains(var.enabled_imdsv2_regions, "ap-south-1") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.ap-south-1
  }
}

module "imdsv2-ap-southeast-1" {
  for_each = contains(var.enabled_imdsv2_regions, "ap-southeast-1") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.ap-southeast-1
  }
}

module "imdsv2-ap-southeast-2" {
  for_each = contains(var.enabled_imdsv2_regions, "ap-southeast-2") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.ap-southeast-2
  }
}

module "imdsv2-ca-central-1" {
  for_each = contains(var.enabled_imdsv2_regions, "ca-central-1") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.ca-central-1
  }
}

module "imdsv2-eu-central-1" {
  for_each = contains(var.enabled_imdsv2_regions, "eu-central-1") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.eu-central-1
  }
}

module "imdsv2-eu-north-1" {
  for_each = contains(var.enabled_imdsv2_regions, "eu-north-1") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.eu-north-1
  }
}

module "imdsv2-eu-west-1" {
  for_each = contains(var.enabled_imdsv2_regions, "eu-west-1") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.eu-west-1
  }
}

module "imdsv2-eu-west-2" {
  for_each = contains(var.enabled_imdsv2_regions, "eu-west-2") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.eu-west-2
  }
}

module "imdsv2-eu-west-3" {
  for_each = contains(var.enabled_imdsv2_regions, "eu-west-3") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.eu-west-3
  }
}

module "imdsv2-sa-east-1" {
  for_each = contains(var.enabled_imdsv2_regions, "sa-east-1") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.sa-east-1
  }
}

module "imdsv2-us-east-1" {
  for_each = contains(var.enabled_imdsv2_regions, "us-east-1") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.us-east-1
  }
}

module "imdsv2-us-east-2" {
  for_each = contains(var.enabled_imdsv2_regions, "us-east-2") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.us-east-2
  }
}

module "imdsv2-us-west-1" {
  for_each = contains(var.enabled_imdsv2_regions, "us-west-1") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.us-west-1
  }
}

module "imdsv2-us-west-2" {
  for_each = contains(var.enabled_imdsv2_regions, "us-west-2") ? local.enabled : local.not_enabled

  source = "./modules/imdsv2"
  providers = {
    aws = aws.us-west-2
  }
}
