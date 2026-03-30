variable "pagerduty_integration_key" {
  default     = "test-integration-key"
  description = "Non-default value used by unit tests. Leave as default for normal use"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map(any)
}