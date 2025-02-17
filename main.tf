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
  unauthorised_api_calls_log_metric_filter_name       = "unauthorised-api-calls-${terraform.workspace}"
  sign_in_without_mfa_metric_filter_name              = "sign-in-without-mfa-${terraform.workspace}"
  root_account_usage_metric_filter_name               = "root-account-usage-${terraform.workspace}"
  iam_policy_changes_metric_filter_name               = "iam-policy-changes-${terraform.workspace}"
  cloudtrail_configuration_changes_metric_filter_name = "cloudtrail-configuration-changes-${terraform.workspace}"
  sign_in_failures_metric_filter_name                 = "sign-in-failures-${terraform.workspace}"
  cmk_removal_metric_filter_name                      = "cmk-removal-${terraform.workspace}"
  s3_bucket_policy_changes_metric_filter_name         = "s3-bucket-policy-changes-${terraform.workspace}"
  config_configuration_changes_metric_filter_name     = "config-configuration-changes-${terraform.workspace}"
  security_group_changes_metric_filter_name           = "security-group-changes-${terraform.workspace}"
  nacl_changes_metric_filter_name                     = "nacl-changes-${terraform.workspace}"
  network_gateway_changes_metric_filter_name          = "network-gateway-changes-${terraform.workspace}"
  route_table_changes_metric_filter_name              = "route-table-changes-${terraform.workspace}"
  vpc_changes_metric_filter_name                      = "vpc-changes-${terraform.workspace}"
  admin_role_usage_metric_filter_name                 = "admin-role-usage-${terraform.workspace}"

  tags = var.tags
}



