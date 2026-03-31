variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map(any)
}

variable "pagerduty_integration_key" {
  type        = string
  description = "PagerDuty integration key for IAM exposed credential alerts."
}

variable "credential_responder_role_name" {
  default     = "credential-responder-lambda"
  description = "Name for the IAM role used by the credential responder Lambda. Override in tests to avoid naming collisions."
  type        = string
}

variable "credential_responder_lambda_name" {
  default     = "iam-credential-responder"
  description = "Name for the credential responder Lambda function. Override in tests to avoid naming collisions."
  type        = string
}
