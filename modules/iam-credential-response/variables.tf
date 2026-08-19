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

variable "iam_credential_response_kms_name" {
  default     = "alias/iam-credential-response"
  description = "Alias name for the IAM credential response KMS key. Must be prefixed with 'alias/'."
  type        = string
}

variable "iam_credential_response_multi_region_kms_name" {
  default     = "alias/iam-credential-response-multi-region"
  description = "Alias name for the IAM credential response multi-region KMS key. Must be prefixed with 'alias/'."
  type        = string
}
