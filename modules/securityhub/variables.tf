variable "enable_securityhub_alerts" {
  default     = false
  description = "Flag to indicate if alerting resources should be created in the region"
  type        = bool
}

variable "sechub_eventbridge_rule_name" {
  description = "SecurityHub Eventbridge rule name"
  default     = "sechub_high_and_critical_findings"
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
  default     = ""
  description = "A PagerDuty integration key to pass into a PagerDuty integration"
  type        = string
}
variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map(any)
}