variable "iam_role_arn" {
  type        = string
  description = "IAM role ARN for the AWS Backup service role"
}

variable "tags" {
  type        = map
  description = "Tags to apply to resources, where applicable"
  default     = {}
}
