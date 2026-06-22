module "ssm-baseline-eu-west-1" {
  for_each  = contains(var.enabled_ssm_baseline_regions, "eu-west-1") ? local.enabled : local.not_enabled
  source    = "./modules/ssm"
  providers = { aws = aws.eu-west-1 }

  create_session_manager_logging_iam_policy = local.enable_session_manager_logging
  enable_session_manager_logging            = local.enable_session_manager_logging && contains(var.session_manager_logging_regions, "eu-west-1")
  session_manager_logging_regions           = var.session_manager_logging_regions
  session_manager_idle_timeout_minutes      = var.session_manager_idle_timeout_minutes
  session_manager_log_kms_key_id            = var.session_manager_log_kms_key_id
  session_manager_log_retention_in_days     = local.session_manager_log_retention_in_days
  tags                                      = var.tags
}

module "ssm-baseline-eu-west-2" {
  for_each  = contains(var.enabled_ssm_baseline_regions, "eu-west-2") ? local.enabled : local.not_enabled
  source    = "./modules/ssm"
  providers = { aws = aws.eu-west-2 }

  enable_session_manager_logging        = local.enable_session_manager_logging && contains(var.session_manager_logging_regions, "eu-west-2")
  session_manager_idle_timeout_minutes  = var.session_manager_idle_timeout_minutes
  session_manager_log_kms_key_id        = var.session_manager_log_kms_key_id
  session_manager_log_retention_in_days = local.session_manager_log_retention_in_days
  tags                                  = var.tags
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
