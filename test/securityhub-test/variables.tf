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

variable "enable_securityhub_slack_alerts" {
  default     = false
  description = "Flag to indicate if Slack alerting resources should be created in the region"
  type        = bool
}

variable "securityhub_slack_alerts_scope" {
  description = "List of the criticality levels covered by the security hub alerts"
  type        = list(string)
  default     = ["CRITICAL", "HIGH"]
}

variable "pagerduty_integration_key" {
  description = "A PagerDuty integration key to pass into a PagerDuty integration"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(any)
  default     = {}
}