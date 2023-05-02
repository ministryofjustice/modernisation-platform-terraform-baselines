variable "iam_role_arn" {
  type        = string
  description = "Role ARN for VPC Flow Logs"
}

variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map(any)
}

variable "retention_days" {
  default     = 400
  description = "Retention days for logs"
  type        = number
}
