variable "pagerduty_integration_key" {
  type        = string
  description = "PagerDuty integration key for IAM exposed credential alerts."
}

variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map(any)
}
