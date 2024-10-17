variable "sechub_eventbridge_rule_name" {
  description = "SecurityHub Eventbridge rule name"
  default     = "sechub_high_and_critical_findings"
}

variable "sechub_sns_topic_name" {
  description = "SecurityHub SNS Topic name"
  default     = "sechub_findings_sns_topic"
}

variable "sechub_sns_kms_key_name" {
  description = "SecurityHub SNS Topic KMS key name"
  default     = "alias/sns-kms-key"
}