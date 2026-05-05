output "securityhub_alarms_sns_topic_arn" {
  value       = module.securityhub-alarms-test.sns_topic_arn
  description = "The ARN of the SNS topic for SecurityHub alarms"
}

output "high_priority_alarms_topic_arn" {
  value       = module.securityhub-alarms-test.high_priority_alarms_topic_arn
  description = "The ARN of the SNS topic for high-priority alarms"
}

output "securityhub_alarms_kms_key_arn" {
  value       = module.securityhub-alarms-test.securityhub_alarms_kms_key_arn
  description = "The ARN of the KMS key for SecurityHub alarms"
}

output "securityhub_alarms_kms_alias_arn" {
  value       = module.securityhub-alarms-test.securityhub_alarms_kms_alias_arn
  description = "The ARN of the KMS alias for SecurityHub alarms"
}

output "securityhub_alarms_multi_region_kms_key_arn" {
  value       = module.securityhub-alarms-test.securityhub_alarms_multi_region_kms_key_arn
  description = "The ARN of the multi-region KMS key for SecurityHub alarms"
}

output "securityhub_alarms_multi_region_kms_alias_arn" {
  value       = module.securityhub-alarms-test.securityhub_alarms_multi_region_kms_alias_arn
  description = "The ARN of the multi-region KMS alias for SecurityHub alarms"
}

output "unauthorised_api_calls_metric_filter_id" {
  value       = module.securityhub-alarms-test.unauthorised_api_calls_metric_filter_id
  description = "The ID of the CloudWatch metric filter for unauthorised API calls"
}

output "unauthorised_api_calls_alarm_arn" {
  value       = module.securityhub-alarms-test.unauthorised_api_calls_alarm_arn
  description = "The ARN of the CloudWatch alarm for unauthorised API calls"
}

output "sign_in_without_mfa_metric_filter_id" {
  value       = module.securityhub-alarms-test.sign_in_without_mfa_metric_filter_id
  description = "The ID of the CloudWatch metric filter for sign-in without MFA"
}

output "sign_in_without_mfa_alarm_arn" {
  value       = module.securityhub-alarms-test.sign_in_without_mfa_alarm_arn
  description = "The ARN of the CloudWatch alarm for sign-in without MFA"
}

output "root_account_usage_metric_filter_id" {
  value       = module.securityhub-alarms-test.root_account_usage_metric_filter_id
  description = "The ID of the CloudWatch metric filter for root account usage"
}

output "root_account_usage_alarm_arn" {
  value       = module.securityhub-alarms-test.root_account_usage_alarm_arn
  description = "The ARN of the CloudWatch alarm for root account usage"
}

output "iam_policy_changes_metric_filter_ids" {
  value       = module.securityhub-alarms-test.iam_policy_changes_metric_filter_ids
  description = "Map of IAM policy change CloudWatch log metric filter IDs keyed by event name"
}

output "iam_policy_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.iam_policy_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for IAM policy changes"
}

output "cloudtrail_configuration_changes_metric_filter_ids" {
  value       = module.securityhub-alarms-test.cloudtrail_configuration_changes_metric_filter_ids
  description = "Map of CloudTrail configuration change CloudWatch log metric filter IDs keyed by event name"
}

output "cloudtrail_configuration_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.cloudtrail_configuration_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for CloudTrail configuration changes"
}

output "sign_in_failures_metric_filter_id" {
  value       = module.securityhub-alarms-test.sign_in_failures_metric_filter_id
  description = "The ID of the CloudWatch metric filter for sign-in failures"
}

output "sign_in_failures_alarm_arn" {
  value       = module.securityhub-alarms-test.sign_in_failures_alarm_arn
  description = "The ARN of the CloudWatch alarm for sign-in failures"
}

output "cmk_removal_metric_filter_id" {
  value       = module.securityhub-alarms-test.cmk_removal_metric_filter_id
  description = "The ID of the CloudWatch metric filter for CMK removal"
}

output "cmk_removal_alarm_arn" {
  value       = module.securityhub-alarms-test.cmk_removal_alarm_arn
  description = "The ARN of the CloudWatch alarm for CMK removal"
}

output "s3_bucket_policy_changes_metric_filter_ids" {
  value       = module.securityhub-alarms-test.s3_bucket_policy_changes_metric_filter_ids
  description = "Map of S3 bucket policy change CloudWatch log metric filter IDs keyed by event name"
}

output "s3_bucket_policy_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.s3_bucket_policy_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for S3 bucket policy changes"
}

output "config_configuration_changes_metric_filter_ids" {
  value       = module.securityhub-alarms-test.config_configuration_changes_metric_filter_ids
  description = "Map of AWS Config configuration change CloudWatch log metric filter IDs keyed by event name"
}

output "config_configuration_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.config_configuration_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for Config configuration changes"
}

output "security_group_changes_metric_filter_ids" {
  value       = module.securityhub-alarms-test.security_group_changes_metric_filter_ids
  description = "Map of security group change CloudWatch log metric filter IDs keyed by event name"
}

output "security_group_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.security_group_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for security group changes"
}

output "nacl_changes_metric_filter_ids" {
  value       = module.securityhub-alarms-test.nacl_changes_metric_filter_ids
  description = "Map of NACL change CloudWatch log metric filter IDs keyed by event name"
}

output "nacl_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.nacl_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for NACL changes"
}

output "network_gateway_changes_metric_filter_ids" {
  value       = module.securityhub-alarms-test.network_gateway_changes_metric_filter_ids
  description = "Map of network gateway change CloudWatch log metric filter IDs keyed by event name"
}

output "network_gateway_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.network_gateway_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for network gateway changes"
}

output "transit_gateway_changes_metric_filter_ids" {
  value       = module.securityhub-alarms-test.transit_gateway_changes_metric_filter_ids
  description = "Map of transit gateway change CloudWatch log metric filter IDs keyed by event name"
}

output "transit_gateway_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.transit_gateway_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for transit gateway changes"
}

output "route_table_changes_metric_filter_ids" {
  value       = module.securityhub-alarms-test.route_table_changes_metric_filter_ids
  description = "Map of route table change CloudWatch log metric filter IDs keyed by event name"
}

output "route_table_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.route_table_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for route table changes"
}

output "vpc_changes_metric_filter_ids" {
  value       = module.securityhub-alarms-test.vpc_changes_metric_filter_ids
  description = "Map of VPC change CloudWatch log metric filter IDs keyed by event name"
}

output "vpc_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.vpc_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for VPC changes"
}

output "privatelink_new_flow_count_alarm_arn" {
  description = "The ARN of the CloudWatch Alarm for PrivateLink New Flow Count"
  value       = module.securityhub-alarms-test.privatelink_new_flow_count_alarm_arn
}

output "privatelink_active_flow_count_alarm_arn" {
  description = "The ARN of the CloudWatch Alarm for PrivateLink Active Flow Count"
  value       = module.securityhub-alarms-test.privatelink_active_flow_count_alarm_arn
}

output "privatelink_service_new_connection_count_alarm_arn" {
  description = "The ARN of the CloudWatch Alarm for PrivateLink Service New Connection Count"
  value       = module.securityhub-alarms-test.privatelink_service_new_connection_count_alarm_arn
}

output "privatelink_service_active_connection_count_alarm_arn" {
  description = "The ARN of the CloudWatch Alarm for PrivateLink Service Active Connection Count"
  value       = module.securityhub-alarms-test.privatelink_service_active_connection_count_alarm_arn
}

output "disable_alarm_actions_events_metric_filter_id" {
  value       = module.securityhub-alarms-test.disable_alarm_actions_events_metric_filter_id
  description = "The ID of the CloudWatch metric filter for disabled alarm actions"
}

output "disable_alarm_actions_events_alarm_arn" {
  value       = module.securityhub-alarms-test.disable_alarm_actions_events_alarm_arn
  description = "The ARN of the CloudWatch alarm for disabled alarm actions"
}

output "admin_role_usage_alarm_arn" {
  description = "The ARN of the CloudWatch Alarm for admin role usage"
  value       = module.securityhub-alarms-test.admin_role_usage_alarm_arn
}

output "admin_role_usage_metric_filter_id" {
  description = "The ID of the CloudWatch metric filter for admin role usage"
  value       = module.securityhub-alarms-test.admin_role_usage_metric_filter_id
}

output "securityhub_events_metric_filter_ids" {
  description = "The IDs of the CloudWatch metric filters for Security Hub protection events"
  value       = module.securityhub-alarms-test.securityhub_events_metric_filter_ids
}

output "securityhub_events_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for Security Hub protection events"
  value       = module.securityhub-alarms-test.securityhub_events_alarm_arn
}

output "critical_role_trust_relationship_changes_metric_filter_ids" {
  description = "The IDs of the CloudWatch metric filters for critical role trust relationship changes"
  value       = module.securityhub-alarms-test.critical_role_trust_relationship_changes_metric_filter_ids
}

output "critical_role_trust_relationship_changes_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for critical role trust relationship changes"
  value       = module.securityhub-alarms-test.critical_role_trust_relationship_changes_alarm_arn
}

output "admin_role_usage_by_mp_team_metric_filter_id" {
  description = "The ID of the CloudWatch metric filter for admin role usage by the MP team"
  value       = module.securityhub-alarms-test.admin_role_usage_by_mp_team_metric_filter_id
}

output "admin_role_usage_non_mp_team_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for admin role usage outside the MP team"
  value       = module.securityhub-alarms-test.admin_role_usage_non_mp_team_alarm_arn
}

output "admin_role_usage_outside_on_call_hours_metric_filter_id" {
  description = "The ID of the CloudWatch metric filter for admin role usage outside on-call hours"
  value       = module.securityhub-alarms-test.admin_role_usage_outside_on_call_hours_metric_filter_id
}

output "admin_role_usage_outside_on_call_hours_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for admin role usage outside on-call hours"
  value       = module.securityhub-alarms-test.admin_role_usage_outside_on_call_hours_alarm_arn
}

output "orgaccess_role_usage_metric_filter_id" {
  description = "The ID of the CloudWatch metric filter for OrganizationAccountAccessRole usage"
  value       = module.securityhub-alarms-test.orgaccess_role_usage_metric_filter_id
}

output "orgaccess_role_usage_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for OrganizationAccountAccessRole usage"
  value       = module.securityhub-alarms-test.orgaccess_role_usage_alarm_arn
}

output "iam_user_deletion_not_by_automation_metric_filter_id" {
  description = "The ID of the CloudWatch metric filter for IAM user deletion outside automation"
  value       = module.securityhub-alarms-test.iam_user_deletion_not_by_automation_metric_filter_id
}

output "iam_user_deletion_by_untrusted_role_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for IAM user deletion by untrusted roles"
  value       = module.securityhub-alarms-test.iam_user_deletion_by_untrusted_role_alarm_arn
}

output "vpn_changes_metric_filter_ids" {
  description = "The IDs of the CloudWatch metric filters for VPN changes"
  value       = module.securityhub-alarms-test.vpn_changes_metric_filter_ids
}

output "vpn_changes_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for VPN changes"
  value       = module.securityhub-alarms-test.vpn_changes_alarm_arn
}