module "securityhub-alarms-test" {
  source                                                     = "../../modules/securityhub-alarms"
    providers = {
    aws.eu-west-2 = aws
    aws.eu-west-1 = aws.modernisation-platform-eu-west-1
  }
  securityhub_alarms_kms_name                                = var.securityhub_alarms_kms_name
  securityhub_alarms_multi_region_kms_name                   = var.securityhub_alarms_multi_region_kms_name
  securityhub_alarms_multi_region_kms_replica_name           = var.securityhub_alarms_multi_region_kms_replica_name
  securityhub_alarms_sns_topic_name                          = var.securityhub_alarms_sns_topic_name
  unauthorised_api_calls_alarm_name                          = var.unauthorised_api_calls_alarm_name
  unauthorised_api_calls_log_metric_filter_name              = var.unauthorised_api_calls_log_metric_filter_name
  sign_in_without_mfa_alarm_name                             = var.sign_in_without_mfa_alarm_name
  sign_in_without_mfa_metric_filter_name                     = var.sign_in_without_mfa_metric_filter_name
  root_account_usage_alarm_name                              = var.root_account_usage_alarm_name
  root_account_usage_metric_filter_name                      = var.root_account_usage_metric_filter_name
  iam_policy_changes_alarm_name                              = var.iam_policy_changes_alarm_name
  iam_policy_changes_metric_filter_name                      = var.iam_policy_changes_metric_filter_name
  cloudtrail_configuration_changes_alarm_name                = var.cloudtrail_configuration_changes_alarm_name
  cloudtrail_configuration_changes_metric_filter_name        = var.cloudtrail_configuration_changes_metric_filter_name
  sign_in_failures_alarm_name                                = var.sign_in_failures_alarm_name
  sign_in_failures_metric_filter_name                        = var.sign_in_failures_metric_filter_name
  cmk_removal_alarm_name                                     = var.cmk_removal_alarm_name
  cmk_removal_metric_filter_name                             = var.cmk_removal_metric_filter_name
  s3_bucket_policy_changes_alarm_name                        = var.s3_bucket_policy_changes_alarm_name
  s3_bucket_policy_changes_metric_filter_name                = var.s3_bucket_policy_changes_metric_filter_name
  config_configuration_changes_alarm_name                    = var.config_configuration_changes_alarm_name
  config_configuration_changes_metric_filter_name            = var.config_configuration_changes_metric_filter_name
  security_group_changes_alarm_name                          = var.security_group_changes_alarm_name
  security_group_changes_metric_filter_name                  = var.security_group_changes_metric_filter_name
  nacl_changes_alarm_name                                    = var.nacl_changes_alarm_name
  nacl_changes_metric_filter_name                            = var.nacl_changes_metric_filter_name
  network_gateway_changes_alarm_name                         = var.network_gateway_changes_alarm_name
  network_gateway_changes_metric_filter_name                 = var.network_gateway_changes_metric_filter_name
  route_table_changes_alarm_name                             = var.route_table_changes_alarm_name
  route_table_changes_metric_filter_name                     = var.route_table_changes_metric_filter_name
  vpc_changes_alarm_name                                     = var.vpc_changes_alarm_name
  vpc_changes_metric_filter_name                             = var.vpc_changes_metric_filter_name
  privatelink_new_flow_count_all_alarm_name                  = var.privatelink_new_flow_count_all_alarm_name
  privatelink_active_flow_count_all_alarm_name               = var.privatelink_active_flow_count_all_alarm_name
  privatelink_service_new_connection_count_all_alarm_name    = var.privatelink_service_new_connection_count_all_alarm_name
  privatelink_service_active_connection_count_all_alarm_name = var.privatelink_service_active_connection_count_all_alarm_name
  admin_role_usage_alarm_name                                = var.admin_role_usage_alarm_name
  admin_role_usage_metric_filter_name                        = var.admin_role_usage_metric_filter_name
}