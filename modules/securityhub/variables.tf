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
variable "central_event_bus_arn" {
  description = "ARN of the central EventBridge event bus (typically in observability-platform eu-west-2) to forward Security Hub finding events to."
  type        = string
  default     = ""
}

variable "enable_securityhub_event_forwarding" {
  description = "When true, forwards matching Security Hub findings (NEW + severities in securityhub_slack_alerts_scope) to central_event_bus_arn."
  type        = bool
  default     = false
}

variable "forwarding_event_scope" {
  description = "List of severity labels that should be forwarded to the central EventBridge bus."
  type        = list(string)
  default     = ["CRITICAL, HIGH"]
}
