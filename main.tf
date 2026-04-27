data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
module "cloudtrail" {
  source                           = "./modules/cloudtrail"
  cloudtrail_kms_key               = var.cloudtrail_kms_key
  cloudtrail_bucket                = local.cloudtrail_bucket
  enable_cloudtrail_s3_mgmt_events = var.enable_cloudtrail_s3_mgmt_events
  tags                             = var.tags
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
  unauthorised_api_calls_log_metric_filter_name                  = "unauthorised-api-calls-${local.workspace_name}"
  sign_in_without_mfa_metric_filter_name                         = "sign-in-without-mfa-${local.workspace_name}"
  root_account_usage_metric_filter_name                          = "root-account-usage-${local.workspace_name}"
  iam_policy_changes_metric_filter_name                          = "iam-policy-changes-${local.workspace_name}"
  cloudtrail_configuration_changes_metric_filter_name            = "cloudtrail-configuration-changes-${local.workspace_name}"
  sign_in_failures_metric_filter_name                            = "sign-in-failures-${local.workspace_name}"
  cmk_removal_metric_filter_name                                 = "cmk-removal-${local.workspace_name}"
  s3_bucket_policy_changes_metric_filter_name                    = "s3-bucket-policy-changes-${local.workspace_name}"
  disable_alarm_actions_events_metric_filter_name                = "disable-alarm-actions-alerting-${local.workspace_name}"
  disable_alarm_actions_events_metric_name                       = "disable-alarm-actions-${local.workspace_name}"
  secrets_manager_events_core_accounts_mp_all_metric_filter_name  = "secrets-manager-cloudtrail-events-mp-all-${local.workspace_name}"
  secrets_manager_events_core_accounts_mp_team_metric_filter_name = "secrets-manager-cloudtrail-events-mp-team-${local.workspace_name}"
  s3_object_deletions_excluding_tf_lock_files_metric_filter_name  = "s3-object-deletions-excluding-tf-lock-files-${local.workspace_name}"
  ec2_termination_in_core_shared_services_metric_filter_name      = "ec2-termination-in-core-shared-services-${local.workspace_name}"
  config_configuration_changes_metric_filter_name                = "config-configuration-changes-${local.workspace_name}"
  security_group_changes_metric_filter_name                      = "security-group-changes-${local.workspace_name}"
  nacl_changes_metric_filter_name                                = "nacl-changes-${local.workspace_name}"
  network_gateway_changes_metric_filter_name                     = "network-gateway-changes-${local.workspace_name}"
  transit_gateway_changes_metric_filter_name                     = "transit-gateway-changes-${local.workspace_name}"
  vpn_changes_metric_filter_name                                 = "vpn-changes-${local.workspace_name}"
  network_firewall_changes_metric_filter_name                    = "network-firewall-changes-${local.workspace_name}"
  route_table_changes_metric_filter_name                         = "route-table-changes-${local.workspace_name}"
  vpc_changes_metric_filter_name                                 = "vpc-changes-${local.workspace_name}"
  critical_role_trust_relationship_changes_metric_filter_name = "critical-role-trust-relationship-changes-${local.workspace_name}"
  admin_role_usage_metric_filter_name                            = "admin-role-usage-${local.workspace_name}"
  orgaccess_role_usage_metric_filter_name                        = "orgaccess-role-usage-${local.workspace_name}"
  iam_user_deletion_not_by_automation_metric_filter_name = "iam-user-deletion-not-by-automation-${local.workspace_name}"
  superadmin_role_usage_metric_filter_name                       = "modernisation-platform-superadmin-role-usage-${local.workspace_name}"
  superadmin_user_deletion_metric_filter_name                    = "modernisation-platform-superadmin-user-deletion-${local.workspace_name}"
  superadmin_user_access_key_creation_metric_filter_name = "modernisation-platform-superadmin-user-access-key-creation-${local.workspace_name}"
  securityhub_events_metric_filter_name                          = "securityhub-events-alerting-${local.workspace_name}"
  securityhub_events_metric_name                                 = "critical-events-${local.workspace_name}"

  high_priority_pagerduty_key = var.high_priority_pagerduty_integration_key

  tags = var.tags
}
