module "ssm-baseline-eu-west-1" {
  for_each  = contains(var.enabled_ssm_baseline_regions, "eu-west-1") ? local.enabled : local.not_enabled
  source    = "./modules/ssm"
  providers = { aws = aws.eu-west-1 }
}

module "ssm-baseline-eu-west-2" {
  for_each  = contains(var.enabled_ssm_baseline_regions, "eu-west-2") ? local.enabled : local.not_enabled
  source    = "./modules/ssm"
  providers = { aws = aws.eu-west-2 }
}

module "ssm-baseline-eu-west-3" {
  for_each  = contains(var.enabled_ssm_baseline_regions, "eu-west-3") ? local.enabled : local.not_enabled
  source    = "./modules/ssm"
  providers = { aws = aws.eu-west-3 }
}

module "ssm-baseline-eu-central-1" {
  for_each  = contains(var.enabled_ssm_baseline_regions, "eu-central-1") ? local.enabled : local.not_enabled
  source    = "./modules/ssm"
  providers = { aws = aws.eu-central-1 }
}

module "ssm-baseline-us-east-1" {
  for_each  = contains(var.enabled_ssm_baseline_regions, "us-east-1") ? local.enabled : local.not_enabled
  source    = "./modules/ssm"
  providers = { aws = aws.us-east-1 }
}
