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

output "iam_policy_changes_metric_filter_ids" {
  description = "Map of IAM policy change CloudWatch log metric filter IDs keyed by event name. Required because metric filters are created using for_each (one per event) instead of a single resource."

  value = {
    for event_name, metric_filter in aws_cloudwatch_log_metric_filter.iam-policy-changes :
    event_name => metric_filter.id
  }
}

output "iam_policy_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.iam-policy-changes.arn
  description = "The ARN of the CloudWatch alarm for IAM policy changes"
}

output "cloudtrail_configuration_changes_metric_filter_ids" {
  description = "Map of CloudTrail configuration change CloudWatch log metric filter IDs keyed by event name"
  value = {
    for event_name, filter in aws_cloudwatch_log_metric_filter.cloudtrail-configuration-changes :
    event_name => filter.id
  }
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

output "s3_bucket_policy_changes_metric_filter_ids" {
  description = "Map of S3 bucket policy change CloudWatch log metric filter IDs keyed by event name"
  value       = { for event_name, filter in aws_cloudwatch_log_metric_filter.s3-bucket-policy-changes : event_name => filter.id }
}

output "s3_bucket_policy_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.s3-bucket-policy-changes.arn
  description = "The ARN of the CloudWatch alarm for S3 bucket policy changes"
}

output "config_configuration_changes_metric_filter_ids" {
  description = "Map of AWS Config configuration change CloudWatch log metric filter IDs keyed by event name"
  value = {
    for event_name, filter in aws_cloudwatch_log_metric_filter.config-configuration-changes :
    event_name => filter.id
  }
}

output "config_configuration_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.config-configuration-changes.arn
  description = "The ARN of the CloudWatch alarm for Config configuration changes"
}

output "security_group_changes_metric_filter_ids" {
  description = "Map of security group change CloudWatch log metric filter IDs keyed by event name"
  value = {
    for event_name, filter in aws_cloudwatch_log_metric_filter.security-group-changes :
    event_name => filter.id
  }
}

output "security_group_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.security-group-changes.arn
  description = "The ARN of the CloudWatch alarm for security group changes"
}

output "nacl_changes_metric_filter_ids" {
  value       = { for k, v in aws_cloudwatch_log_metric_filter.nacl-changes : k => v.id }
  description = "The IDs of the CloudWatch metric filters for NACL changes, keyed by event name"
}

output "nacl_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.nacl-changes.arn
  description = "The ARN of the CloudWatch alarm for NACL changes"
}

output "network_gateway_changes_metric_filter_ids" {
  value       = { for k, v in aws_cloudwatch_log_metric_filter.network-gateway-changes : k => v.id }
  description = "The IDs of the CloudWatch metric filters for network gateway changes, keyed by event name"
}

output "network_gateway_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.network-gateway-changes.arn
  description = "The ARN of the CloudWatch alarm for network gateway changes"
}

output "route_table_changes_metric_filter_ids" {
  value       = { for k, v in aws_cloudwatch_log_metric_filter.route-table-changes : k => v.id }
  description = "The IDs of the CloudWatch metric filters for route table changes, keyed by event name"
}

output "route_table_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.route-table-changes.arn
  description = "The ARN of the CloudWatch alarm for route table changes"
}

output "vpc_changes_metric_filter_ids" {
  value       = { for k, v in aws_cloudwatch_log_metric_filter.vpc-changes : k => v.id }
  description = "The IDs of the CloudWatch metric filters for VPC changes, keyed by event name"
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

output "transit_gateway_changes_metric_filter_ids" {
  description = "The IDs of the CloudWatch metric filters for transit gateway changes, keyed by event name"
  value       = { transit_gateway_changes = aws_cloudwatch_log_metric_filter.transit-gateway-changes.id }
}

output "transit_gateway_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.transit-gateway-changes.arn
  description = "The ARN of the CloudWatch alarm for transit gateway changes"
}

output "admin_role_usage_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.admin_role_usage.id
  description = "The ID of the CloudWatch metric filter for admin role usage"
}

output "admin_role_usage_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for admin role usage"
  value       = aws_cloudwatch_metric_alarm.admin_role_usage.arn
}

output "admin_role_usage_all_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.admin_role_usage.id
  description = "The ID of the CloudWatch metric filter for all AdministratorAccess role usage"
}

output "admin_role_usage_all_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.admin_role_usage.arn
  description = "The ARN of the CloudWatch alarm for all AdministratorAccess role usage"
}

output "high_priority_alarms_topic_arn" {
  value       = aws_sns_topic.high_priority_alarms_topic.arn
  description = "The ARN of the high-priority alarms SNS topic"
}

output "vpn_changes_metric_filter_ids" {
  description = "The IDs of the CloudWatch metric filters for VPN changes, keyed by event name"
  value       = { vpn_changes = aws_cloudwatch_log_metric_filter.vpn-changes.id }
}

output "vpn_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.vpn-changes.arn
  description = "The ARN of the CloudWatch alarm for VPN changes"
}

output "network_firewall_changes_metric_filter_ids" {
  description = "The IDs of the CloudWatch metric filters for Network Firewall changes, keyed by event name"
  value       = try({ network_firewall_changes = aws_cloudwatch_log_metric_filter.network_firewall_changes[0].id }, {})
}

output "network_firewall_changes_alarm_arn" {
  value       = try(aws_cloudwatch_metric_alarm.network_firewall_changes[0].arn, null)
  description = "The ARN of the CloudWatch alarm for Network Firewall changes"
}

output "disable_alarm_actions_events_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.disable_alarm_actions_events.id
  description = "The ID of the CloudWatch metric filter for disabled alarm actions"
}

output "disable_alarm_actions_events_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.disable_alarm_actions_events.arn
  description = "The ARN of the CloudWatch alarm for disabled alarm actions"
}

output "securityhub_events_metric_filter_ids" {
  description = "The IDs of the CloudWatch metric filters for Security Hub and GuardDuty protection events, keyed by event name"
  value       = { securityhub_events = aws_cloudwatch_log_metric_filter.securityhub_events.id }
}

output "securityhub_events_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.securityhub_events.arn
  description = "The ARN of the CloudWatch alarm for Security Hub and GuardDuty protection events"
}

output "critical_role_trust_relationship_changes_metric_filter_ids" {
  description = "The IDs of the CloudWatch metric filters for critical role trust relationship changes, keyed by role name"
  value       = { critical_role_trust_relationship_changes = aws_cloudwatch_log_metric_filter.critical_role_trust_relationship_changes.id }
}

output "critical_role_trust_relationship_changes_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.critical_role_trust_relationship_changes.arn
  description = "The ARN of the CloudWatch alarm for critical role trust relationship changes"
}

output "admin_role_usage_by_mp_team_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.admin_role_usage_by_mp_team.id
  description = "The ID of the CloudWatch metric filter for admin role usage by the MP team"
}

output "admin_role_usage_non_mp_team_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.admin_role_usage_non_mp_team.arn
  description = "The ARN of the CloudWatch alarm for admin role usage outside the MP team"
}

output "admin_role_usage_outside_on_call_hours_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.admin_role_usage_outside_on_call_hours.id
  description = "The ID of the CloudWatch metric filter for admin role usage outside on-call hours"
}

output "admin_role_usage_outside_on_call_hours_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.admin_role_usage_outside_on_call_outside_on_call_hours.arn
  description = "The ARN of the CloudWatch alarm for admin role usage outside on-call hours"
}

output "orgaccess_role_usage_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.orgaccess_role_usage.id
  description = "The ID of the CloudWatch metric filter for OrganizationAccountAccessRole usage"
}

output "orgaccess_role_usage_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.orgaccess_role_usage.arn
  description = "The ARN of the CloudWatch alarm for OrganizationAccountAccessRole usage"
}

output "iam_user_deletion_not_by_automation_metric_filter_id" {
  value       = aws_cloudwatch_log_metric_filter.iam_user_deletion_not_by_automation.id
  description = "The ID of the CloudWatch metric filter for IAM user deletion not by automation"
}

output "iam_user_deletion_by_untrusted_role_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.iam_user_deletion_by_untrusted_role.arn
  description = "The ARN of the CloudWatch alarm for IAM user deletion by untrusted roles"
}

output "superadmin_role_usage_metric_filter_id" {
  value       = try(aws_cloudwatch_log_metric_filter.superadmin_role_usage[0].id, null)
  description = "The ID of the CloudWatch metric filter for SuperAdmin role usage"
}

output "superadmin_role_usage_alarm_arn" {
  value       = try(aws_cloudwatch_metric_alarm.superadmin_role_usage[0].arn, null)
  description = "The ARN of the CloudWatch alarm for SuperAdmin role usage"
}

output "superadmin_user_deletion_metric_filter_id" {
  value       = try(aws_cloudwatch_log_metric_filter.superadmin_user_deletion[0].id, null)
  description = "The ID of the CloudWatch metric filter for SuperAdmin user deletion"
}

output "superadmin_user_deletion_alarm_arn" {
  value       = try(aws_cloudwatch_metric_alarm.superadmin_user_deletion[0].arn, null)
  description = "The ARN of the CloudWatch alarm for SuperAdmin user deletion"
}

output "superadmin_user_access_key_creation_metric_filter_id" {
  value       = try(aws_cloudwatch_log_metric_filter.superadmin_user_access_key_creation[0].id, null)
  description = "The ID of the CloudWatch metric filter for SuperAdmin user access key creation"
}

output "superadmin_user_access_key_creation_alarm_arn" {
  value       = try(aws_cloudwatch_metric_alarm.superadmin_user_access_key_creation[0].arn, null)
  description = "The ARN of the CloudWatch alarm for SuperAdmin user access key creation"
}

output "secrets_manager_events_core_accounts_mp_all_metric_filter_ids" {
  description = "The IDs of the CloudWatch metric filters for non-automation Secrets Manager events in MP accounts, keyed by event name"
  value       = { for k, v in aws_cloudwatch_log_metric_filter.secrets_manager_events_core_accounts_mp_all : k => v.id }
}

output "secrets_manager_events_core_accounts_mp_team_metric_filter_ids" {
  description = "The IDs of the CloudWatch metric filters for non-automation Secrets Manager events by MP team members, keyed by event name"
  value       = { for k, v in aws_cloudwatch_log_metric_filter.secrets_manager_events_core_accounts_mp_team : k => v.id }
}

output "secrets_manager_core_account_events_not_by_mp_team_alarm_arn" {
  value       = try(aws_cloudwatch_metric_alarm.secrets_manager_core_account_events_not_by_mp_team[0].arn, null)
  description = "The ARN of the CloudWatch alarm for Secrets Manager events outside MP team and automation"
}

output "s3_object_deletions_excluding_tf_lock_files_metric_filter_id" {
  value       = try(aws_cloudwatch_log_metric_filter.s3_object_deletions_excluding_tf_lock_files[0].id, null)
  description = "The ID of the CloudWatch metric filter for S3 object deletions excluding Terraform lock files"
}

output "s3_object_deletions_excluding_tf_lock_files_alarm_arn" {
  value       = try(aws_cloudwatch_metric_alarm.s3_object_deletions_excluding_tf_lock_files[0].arn, null)
  description = "The ARN of the CloudWatch alarm for S3 object deletions excluding Terraform lock files"
}

output "ec2_termination_in_core_shared_services_metric_filter_id" {
  value       = try(aws_cloudwatch_log_metric_filter.ec2_termination_in_core_shared_services[0].id, null)
  description = "The ID of the CloudWatch metric filter for EC2 termination in core-shared-services"
}

output "ec2_termination_in_core_shared_services_alarm_arn" {
  value       = try(aws_cloudwatch_metric_alarm.ec2_termination_in_core_shared_services[0].arn, null)
  description = "The ARN of the CloudWatch alarm for EC2 termination in core-shared-services"
}