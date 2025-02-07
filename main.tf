data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_iam_account_alias" "current" {}

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
  unauthorised_api_calls_alarm_name                          = "unauthorised-api-calls-${local.account_alias}"
  sign_in_without_mfa_alarm_name                             = "sign-in-without-mfa-${local.account_alias}"
  root_account_usage_alarm_name                              = "root-account-usage-${local.account_alias}"
  iam_policy_changes_alarm_name                              = "iam-policy-changes-${local.account_alias}"
  cloudtrail_configuration_changes_alarm_name                = "cloudtrail-configuration-changes-${local.account_alias}"
  sign_in_failures_alarm_name                                = "sign-in-failures-${local.account_alias}"
  cmk_removal_alarm_name                                     = "cmk-removal-${local.account_alias}"
  s3_bucket_policy_changes_alarm_name                        = "s3-bucket-policy-changes-${local.account_alias}"
  config_configuration_changes_alarm_name                    = "config-configuration-changes-${local.account_alias}"
  security_group_changes_alarm_name                          = "security-group-changes-${local.account_alias}"
  nacl_changes_alarm_name                                    = "nacl-changes-${local.account_alias}"
  network_gateway_changes_alarm_name                         = "network-gateway-changes-${local.account_alias}"
  route_table_changes_alarm_name                             = "route-table-changes-${local.account_alias}"
  vpc_changes_alarm_name                                     = "vpc-changes-${local.account_alias}"
  privatelink_new_flow_count_all_alarm_name                  = "privatelink-new-flow-count-all-${local.account_alias}"
  privatelink_active_flow_count_all_alarm_name               = "privatelink-active-flow-count-all-${local.account_alias}"
  privatelink_service_new_connection_count_all_alarm_name    = "privatelink-service-new-connection-count-all-${local.account_alias}"
  privatelink_service_active_connection_count_all_alarm_name = "privatelink-service-active-connection-count-all-${local.account_alias}"
  admin_role_usage_alarm_name                                = "admin-role-usage-${local.account_alias}"

  tags = var.tags
}



