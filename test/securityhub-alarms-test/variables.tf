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