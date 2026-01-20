variable "sechub_eventbridge_rule_name" {
  description = "SecurityHub Eventbridge rule name"
  default     = "sechub_critical_findings"
  type        = string
}

variable "sechub_sns_topic_name" {
  description = "SecurityHub SNS Topic name"
  default     = "sechub_findings_sns_topic"
  type        = string
}

variable "sechub_sns_kms_key_name" {
  description = "SecurityHub SNS Topic KMS key name"
  default     = "alias/sns-kms-key"
  type        = string
}

variable "pagerduty_integration_key" {
  description = "A PagerDuty integration key to pass into a PagerDuty integration"
  type        = string
  default     = ""
}

variable "enable_securityhub_slack_alerts" {
  description = "Flag to indicate if Slack alerting resources should be created in the account"
  type        = bool
  default     = false
}

variable "securityhub_slack_alerts_scope" {
  description = "List of the criticality levels covered by the security hub alerts. Minimum is CRITICAL"
  type        = list(string)
  default     = ["CRITICAL"]
}

variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map(any)
}