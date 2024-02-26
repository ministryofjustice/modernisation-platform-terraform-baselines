variable "iam_role_arn" {
  type        = string
  description = "IAM role ARN for the AWS Backup service role"
}

variable "sns_backup_topic_key" {
  type        = string
  default     = "alias/aws/sns"
  description = "KMS key used to encrypt backup failure SNS topic"
}

variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map(any)
}
