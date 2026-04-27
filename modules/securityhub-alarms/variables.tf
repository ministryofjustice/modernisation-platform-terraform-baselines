variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map(any)
}

variable "securityhub_alarms_kms_name" {
  default = "alias/securityhub-alarms_key"
  type    = string
}

variable "securityhub_alarms_multi_region_kms_name" {
  default = "alias/securityhub-alarms-key-multi-region"
  type    = string
}

variable "securityhub_alarms_sns_topic_name" {
  default = "securityhub-alarms"
  type    = string
}

variable "high_priority_sns_topic_name" {
  default = "high-priority-alarms-topic"
  type    = string
}

variable "unauthorised_api_calls_log_metric_filter_name" {
  default = "unauthorised-api-calls"
  type    = string
}

variable "unauthorised_api_calls_alarm_name" {
  default = "unauthorised-api-calls"
  type    = string
}

variable "sign_in_without_mfa_metric_filter_name" {
  default = "sign-in-without-mfa"
  type    = string
}

variable "sign_in_without_mfa_alarm_name" {
  default = "sign-in-without-mfa"
  type    = string
}

variable "root_account_usage_metric_filter_name" {
  default = "root-account-usage"
  type    = string
}

variable "root_account_usage_alarm_name" {
  default = "root-account-usage"
  type    = string
}

variable "iam_policy_changes_metric_filter_name" {
  default = "iam-policy-changes"
  type    = string
}

variable "iam_policy_changes_alarm_name" {
  default = "iam-policy-changes"
  type    = string
}

variable "cloudtrail_configuration_changes_metric_filter_name" {
  default = "cloudtrail-configuration-changes"
  type    = string
}

variable "cloudtrail_configuration_changes_alarm_name" {
  default = "cloudtrail-configuration-changes"
  type    = string
}

variable "sign_in_failures_metric_filter_name" {
  default = "sign-in-failures"
  type    = string
}

variable "sign_in_failures_alarm_name" {
  default = "sign-in-failures"
  type    = string
}

variable "cmk_removal_metric_filter_name" {
  default = "cmk-removal"
  type    = string
}

variable "cmk_removal_alarm_name" {
  default = "cmk-removal"
  type    = string
}

variable "s3_bucket_policy_changes_metric_filter_name" {
  default = "s3-bucket-policy-changes"
  type    = string
}

variable "s3_bucket_policy_changes_alarm_name" {
  default = "s3-bucket-policy-changes"
  type    = string
}

variable "disable_alarm_actions_events_metric_filter_name" {
  default = "disable-alarm-actions-alerting"
  type    = string
}

variable "disable_alarm_actions_events_metric_name" {
  default = "disable-alarm-actions"
  type    = string
}

variable "disable_alarm_actions_events_alarm_name" {
  default = "disable-alarms-actions-events"
  type    = string
}

variable "secrets_manager_events_core_accounts_mp_all_metric_filter_name" {
  default = "secrets-manager-cloudtrail-events-mp-all"
  type    = string
}

variable "secrets_manager_events_core_accounts_mp_team_metric_filter_name" {
  default = "secrets-manager-cloudtrail-events-mp-team"
  type    = string
}

variable "secrets_manager_core_account_events_not_by_mp_team_alarm_name" {
  default = "secrets-manager-events-core-account-non-mp-team"
  type    = string
}

variable "s3_object_deletions_excluding_tf_lock_files_metric_filter_name" {
  default = "s3-object-deletions-excluding-tf-lock-files"
  type    = string
}

variable "s3_object_deletions_excluding_tf_lock_files_alarm_name" {
  default = "s3-object-deletions-excluding-tf-lock-files"
  type    = string
}

variable "ec2_termination_in_core_shared_services_metric_filter_name" {
  default = "ec2-termination-in-core-shared-services"
  type    = string
}

variable "ec2_termination_in_core_shared_services_alarm_name" {
  default = "ec2-termination-in-core-shared-services"
  type    = string
}

variable "config_configuration_changes_metric_filter_name" {
  default = "config-configuration-changes"
  type    = string
}

variable "config_configuration_changes_alarm_name" {
  default = "config-configuration-changes"
  type    = string
}

variable "security_group_changes_metric_filter_name" {
  default = "security-group-changes"
  type    = string
}

variable "security_group_changes_alarm_name" {
  default = "security-group-changes"
  type    = string
}

variable "nacl_changes_metric_filter_name" {
  default = "nacl-changes"
  type    = string
}

variable "nacl_changes_alarm_name" {
  default = "nacl-changes"
  type    = string
}

variable "network_gateway_changes_metric_filter_name" {
  default = "network-gateway-changes"
  type    = string
}

variable "network_gateway_changes_alarm_name" {
  default = "network-gateway-changes"
  type    = string
}

variable "vpn_changes_metric_filter_name" {
  default = "vpn-changes"
  type    = string
}

variable "vpn_changes_alarm_name" {
  default = "vpn-changes"
  type    = string
}

variable "network_firewall_changes_metric_filter_name" {
  default = "network-firewall-changes"
  type    = string
}

variable "network_firewall_changes_alarm_name" {
  default = "network-firewall-changes"
  type    = string
}

variable "transit_gateway_changes_metric_filter_name" {
  default = "transit-gateway-changes"
  type    = string
}

variable "transit_gateway_changes_alarm_name" {
  default = "transit-gateway-changes"
  type    = string
}

variable "route_table_changes_metric_filter_name" {
  default = "route-table-changes"
  type    = string
}

variable "route_table_changes_alarm_name" {
  default = "route-table-changes"
  type    = string
}

variable "vpc_changes_metric_filter_name" {
  default = "vpc-changes"
  type    = string
}

variable "vpc_changes_alarm_name" {
  default = "vpc-changes"
  type    = string
}

variable "error_port_allocation_metric_filter_name" {
  default = "ErrorPortAllocation"
  type    = string
}

variable "error_port_allocation_alarm_name" {
  default = "NAT-Gateway-ErrorPortAllocation"
  type    = string
}

variable "nat_packets_drop_count_all_alarm_name" {
  default = "NAT-PacketsDropCount-AllGateways"
  type    = string
}

variable "privatelink_new_flow_count_all_alarm_name" {
  default = "PrivateLink-NewFlowCount-AllEndpoints"
  type    = string
}

variable "privatelink_active_flow_count_all_alarm_name" {
  default = "PrivateLink-ActiveFlowCount-AllEndpoints"
  type    = string
}

variable "privatelink_service_new_connection_count_all_alarm_name" {
  default = "PrivateLink-Service-NewConnectionCount-AllServices"
  type    = string
}

variable "privatelink_service_active_connection_count_all_alarm_name" {
  default = "PrivateLink-Service-ActiveConnectionCount-AllServices"
  type    = string
}

variable "admin_role_usage_metric_filter_name" {
  default = "admin-role-usage"
  type    = string
}

variable "admin_role_usage_alarm_name" {
  default = "admin-role-usage"
  type    = string
}

variable "critical_role_trust_relationship_changes_metric_filter_name" {
  default = "critical-role-trust-relationship-changes"
  type    = string
}

variable "critical_role_trust_relationship_changes_alarm_name" {
  default = "critical-role-trust-relationship-changes"
  type    = string
}

variable "orgaccess_role_usage_metric_filter_name" {
  default = "orgaccess-role-usage"
  type    = string
}

variable "orgaccess_role_usage_alarm_name" {
  default = "orgaccess-role-usage"
  type    = string
}

variable "iam_user_deletion_not_by_automation_metric_filter_name" {
  default = "iam-user-deletion-not-by-automation"
  type    = string
}

variable "iam_user_deletion_by_untrusted_role_alarm_name" {
  default = "iam-user-deletion-by-untrusted-role"
  type    = string
}

variable "superadmin_role_usage_metric_filter_name" {
  default = "modernisation-platform-superadmin-role-usage"
  type    = string
}

variable "superadmin_role_usage_alarm_name" {
  default = "modernisation-platform-superadmin-role-usage"
  type    = string
}

variable "superadmin_user_deletion_metric_filter_name" {
  default = "modernisation-platform-superadmin-user-deletion"
  type    = string
}

variable "superadmin_user_deletion_alarm_name" {
  default = "modernisation-platform-superadmin-user-deletion"
  type    = string
}

variable "superadmin_user_access_key_creation_metric_filter_name" {
  default = "modernisation-platform-superadmin-user-access-key-creation"
  type    = string
}

variable "superadmin_user_access_key_creation_alarm_name" {
  default = "modernisation-platform-superadmin-user-access-key-creation"
  type    = string
}

variable "securityhub_events_metric_filter_name" {
  default = "securityhub-events-alerting"
  type    = string
}

variable "securityhub_events_metric_name" {
  default = "critical-events"
  type    = string
}

variable "securityhub_events_alarm_name" {
  default = "securityhub-events-alerting"
  type    = string
}

variable "high_priority_pagerduty_key" {
  default = ""
  type    = string
}

variable "cloudtrail_log_group_name" {
  description = "CloudWatch Logs log group name used by CloudTrail metric filters"
  type        = string
  default     = "cloudtrail"
}