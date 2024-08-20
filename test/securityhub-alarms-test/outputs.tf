output "securityhub_alarms_sns_topic_arn" {
  value       = module.securityhub-alarms-test.sns_topic_arn
  description = "The ARN of the SNS topic for SecurityHub alarms"
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

output "iam_policy_changes_metric_filter_id" {
  value       = module.securityhub-alarms-test.iam_policy_changes_metric_filter_id
  description = "The ID of the CloudWatch metric filter for IAM policy changes"
}

output "iam_policy_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.iam_policy_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for IAM policy changes"
}

output "cloudtrail_configuration_changes_metric_filter_id" {
  value       = module.securityhub-alarms-test.cloudtrail_configuration_changes_metric_filter_id
  description = "The ID of the CloudWatch metric filter for CloudTrail configuration changes"
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

output "s3_bucket_policy_changes_metric_filter_id" {
  value       = module.securityhub-alarms-test.s3_bucket_policy_changes_metric_filter_id
  description = "The ID of the CloudWatch metric filter for S3 bucket policy changes"
}

output "s3_bucket_policy_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.s3_bucket_policy_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for S3 bucket policy changes"
}

output "config_configuration_changes_metric_filter_id" {
  value       = module.securityhub-alarms-test.config_configuration_changes_metric_filter_id
  description = "The ID of the CloudWatch metric filter for Config configuration changes"
}

output "config_configuration_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.config_configuration_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for Config configuration changes"
}

output "security_group_changes_metric_filter_id" {
  value       = module.securityhub-alarms-test.security_group_changes_metric_filter_id
  description = "The ID of the CloudWatch metric filter for security group changes"
}

output "security_group_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.security_group_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for security group changes"
}

output "nacl_changes_metric_filter_id" {
  value       = module.securityhub-alarms-test.nacl_changes_metric_filter_id
  description = "The ID of the CloudWatch metric filter for NACL changes"
}

output "nacl_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.nacl_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for NACL changes"
}

output "network_gateway_changes_metric_filter_id" {
  value       = module.securityhub-alarms-test.network_gateway_changes_metric_filter_id
  description = "The ID of the CloudWatch metric filter for network gateway changes"
}

output "network_gateway_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.network_gateway_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for network gateway changes"
}

output "route_table_changes_metric_filter_id" {
  value       = module.securityhub-alarms-test.route_table_changes_metric_filter_id
  description = "The ID of the CloudWatch metric filter for route table changes"
}

output "route_table_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.route_table_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for route table changes"
}

output "vpc_changes_metric_filter_id" {
  value       = module.securityhub-alarms-test.vpc_changes_metric_filter_id
  description = "The ID of the CloudWatch metric filter for VPC changes"
}

output "vpc_changes_alarm_arn" {
  value       = module.securityhub-alarms-test.vpc_changes_alarm_arn
  description = "The ARN of the CloudWatch alarm for VPC changes"
}

output "nat_gateway_error_port_allocation_metric_filter_id" {
  description = "The ID of the CloudWatch Log Metric Filter for NAT Gateway Error Port Allocation"
  value       = module.securityhub-alarms-test.nat_gateway_error_port_allocation_metric_filter_id
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