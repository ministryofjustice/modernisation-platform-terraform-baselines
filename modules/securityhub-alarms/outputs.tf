output "sns_topic_arn" {
  value       = aws_sns_topic.securityhub-alarms.arn
  description = "Security benchmark Cloudwatch alarms SNS topic ARN"
}
output "securityhub_alarms_kms_key_arn" {
  value       = aws_kms_key.securityhub-alarms.arn
  description = "The ARN of the KMS key for SecurityHub alarms"
}

output "securityhub_alarms_kms_alias_arn" {
  value       = aws_kms_alias.securityhub-alarms.arn
  description = "The ARN of the KMS alias for SecurityHub alarms"
}

output "securityhub_alarms_multi_region_kms_key_arn" {
  value       = aws_kms_key.securityhub_alarms_multi_region.arn
  description = "The ARN of the multi-region KMS key for SecurityHub alarms"
}

output "securityhub_alarms_multi_region_kms_alias_arn" {
  value       = aws_kms_alias.securityhub_alarms_multi_region.arn
  description = "The ARN of the multi-region KMS alias for SecurityHub alarms"
}

output "securityhub_alarms_multi_region_kms_key_replica_arn" {
  value       = aws_kms_replica_key.securityhub-alarms_multi_region_replica.arn
  description = "The ARN of the multi-region replica KMS key for SecurityHub alarms"
}

output "securityhub_alarms_multi_region_kms_alias_replica_arn" {
  value       = aws_kms_alias.securityhub-alarms_multi_region_replica.arn
  description = "The ARN of the multi-region KMS replica alias for SecurityHub alarms"
}

output "unauthorised_api_calls_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.unauthorised-api-calls.id
  description = "The ID of the CloudWatch metric filter for unauthorised API calls"
}

output "unauthorised_api_calls_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.unauthorised-api-calls.arn
  description = "The ARN of the CloudWatch alarm for unauthorised API calls"
}

output "sign_in_without_mfa_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.sign-in-without-mfa.id
  description = "The ID of the CloudWatch metric filter for sign-in without MFA"
}

output "sign_in_without_mfa_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.sign-in-without-mfa.arn
  description = "The ARN of the CloudWatch alarm for sign-in without MFA"
}

output "root_account_usage_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.root-account-usage.id
  description = "The ID of the CloudWatch metric filter for root account usage"
}

output "root_account_usage_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.root-account-usage.arn
  description = "The ARN of the CloudWatch alarm for root account usage"
}

output "iam_policy_changes_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.iam-policy-changes.id
  description = "The ID of the CloudWatch metric filter for IAM policy changes"
}

output "iam_policy_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.iam-policy-changes.arn
  description = "The ARN of the CloudWatch alarm for IAM policy changes"
}

output "cloudtrail_configuration_changes_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.cloudtrail-configuration-changes.id
  description = "The ID of the CloudWatch metric filter for CloudTrail configuration changes"
}

output "cloudtrail_configuration_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.cloudtrail-configuration-changes.arn
  description = "The ARN of the CloudWatch alarm for CloudTrail configuration changes"
}

output "sign_in_failures_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.sign-in-failures.id
  description = "The ID of the CloudWatch metric filter for sign-in failures"
}

output "sign_in_failures_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.sign-in-failures.arn
  description = "The ARN of the CloudWatch alarm for sign-in failures"
}

output "cmk_removal_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.cmk-removal.id
  description = "The ID of the CloudWatch metric filter for CMK removal"
}

output "cmk_removal_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.cmk-removal.arn
  description = "The ARN of the CloudWatch alarm for CMK removal"
}

output "s3_bucket_policy_changes_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.s3-bucket-policy-changes.id
  description = "The ID of the CloudWatch metric filter for S3 bucket policy changes"
}

output "s3_bucket_policy_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.s3-bucket-policy-changes.arn
  description = "The ARN of the CloudWatch alarm for S3 bucket policy changes"
}

output "config_configuration_changes_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.config-configuration-changes.id
  description = "The ID of the CloudWatch metric filter for Config configuration changes"
}

output "config_configuration_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.config-configuration-changes.arn
  description = "The ARN of the CloudWatch alarm for Config configuration changes"
}

output "security_group_changes_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.security-group-changes.id
  description = "The ID of the CloudWatch metric filter for security group changes"
}

output "security_group_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.security-group-changes.arn
  description = "The ARN of the CloudWatch alarm for security group changes"
}

output "nacl_changes_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.nacl-changes.id
  description = "The ID of the CloudWatch metric filter for NACL changes"
}

output "nacl_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.nacl-changes.arn
  description = "The ARN of the CloudWatch alarm for NACL changes"
}

output "network_gateway_changes_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.network-gateway-changes.id
  description = "The ID of the CloudWatch metric filter for network gateway changes"
}

output "network_gateway_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.network-gateway-changes.arn
  description = "The ARN of the CloudWatch alarm for network gateway changes"
}

output "route_table_changes_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.route-table-changes.id
  description = "The ID of the CloudWatch metric filter for route table changes"
}

output "route_table_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.route-table-changes.arn
  description = "The ARN of the CloudWatch alarm for route table changes"
}

output "vpc_changes_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.vpc-changes.id
  description = "The ID of the CloudWatch metric filter for VPC changes"
}

output "vpc_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.vpc-changes.arn
  description = "The ARN of the CloudWatch alarm for VPC changes"
}

output "privatelink_new_flow_count_alarm_arn" {
  description = "The ARN of the CloudWatch Alarm for PrivateLink New Flow Count"
  value       = aws_cloudwatch_metric_alarm.privatelink_new_flow_count_all.arn
}

output "privatelink_active_flow_count_alarm_arn" {
  description = "The ARN of the CloudWatch Alarm for PrivateLink Active Flow Count"
  value       = aws_cloudwatch_metric_alarm.privatelink_active_flow_count_all.arn
}

output "privatelink_service_new_connection_count_alarm_arn" {
  description = "The ARN of the CloudWatch Alarm for PrivateLink Service New Connection Count"
  value       = aws_cloudwatch_metric_alarm.privatelink_service_new_connection_count_all.arn
}

output "privatelink_service_active_connection_count_alarm_arn" {
  description = "The ARN of the CloudWatch Alarm for PrivateLink Service Active Connection Count"
  value       = aws_cloudwatch_metric_alarm.privatelink_service_active_connection_count_all.arn
}

output "admin_role_usage_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.admin_role_usage.id
  description = "The ID of the CloudWatch metric filter for admin role usage"
}

output "admin_role_usage_alarm_arn" {
  description = "The ARN of the CloudWatch Alarm for admin role usage"
  value       = aws_cloudwatch_metric_alarm.admin_role_usage.arn
}