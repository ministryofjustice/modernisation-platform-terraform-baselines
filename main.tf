data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
module "cloudtrail" {
  source = "./modules/cloudtrail"
  providers = {
    aws.replication-region = aws.replication-region
  }
  cloudtrail_kms_key               = var.cloudtrail_kms_key
  cloudtrail_bucket                = local.cloudtrail_bucket
  enable_cloudtrail_s3_mgmt_events = var.enable_cloudtrail_s3_mgmt_events
  # replication_role_arn = module.s3-replication-role.role.arn
  tags = var.tags
}

module "iam" {
  source = "./modules/iam"
}

module "support" {
  source = "./modules/support"
  tags   = var.tags
}

module "securityhub-alarms" {
  source = "./modules/securityhub-alarms"

  depends_on = [module.cloudtrail]

  # Add alias to alarm names
  unauthorised_api_calls_log_metric_filter_name       = "unauthorised-api-calls-${local.workspace_name}"
  sign_in_without_mfa_metric_filter_name              = "sign-in-without-mfa-${local.workspace_name}"
  root_account_usage_metric_filter_name               = "root-account-usage-${local.workspace_name}"
  iam_policy_changes_metric_filter_name               = "iam-policy-changes-${local.workspace_name}"
  cloudtrail_configuration_changes_metric_filter_name = "cloudtrail-configuration-changes-${local.workspace_name}"
  sign_in_failures_metric_filter_name                 = "sign-in-failures-${local.workspace_name}"
  cmk_removal_metric_filter_name                      = "cmk-removal-${local.workspace_name}"
  s3_bucket_policy_changes_metric_filter_name         = "s3-bucket-policy-changes-${local.workspace_name}"
  config_configuration_changes_metric_filter_name     = "config-configuration-changes-${local.workspace_name}"
  security_group_changes_metric_filter_name           = "security-group-changes-${local.workspace_name}"
  nacl_changes_metric_filter_name                     = "nacl-changes-${local.workspace_name}"
  network_gateway_changes_metric_filter_name          = "network-gateway-changes-${local.workspace_name}"
  route_table_changes_metric_filter_name              = "route-table-changes-${local.workspace_name}"
  vpc_changes_metric_filter_name                      = "vpc-changes-${local.workspace_name}"
  admin_role_usage_metric_filter_name                 = "admin-role-usage-${local.workspace_name}"

  tags = var.tags
}



