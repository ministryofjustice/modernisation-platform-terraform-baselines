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

variable "aws_backup_vault_name" {
  default = "everything"
  type    = string
}

variable "production_backup_plan_name" {
  default = "backup-daily-retain-30-days"
  type    = string
}

variable "production_backup_selection_name" {
  default = "is-production-true"
  type    = string
}

variable "non_production_backup_plan_name" {
  default = "backup-daily-cold-storage-monthly-retain-30-days"
  type    = string
}

variable "non_production_backup_selection_name" {
  default = "non-production-backup"
  type    = string
}

variable "backup_aws_sns_topic_name" {
  default = "backup_failure_topic"
  type    = string
}

variable "backup_vault_lock_sns_topic_name" {
  default = "backup_vault_failure_topic"
  type    = string
}

variable "max_vault_retention_days" {
  default     = 30
  description = "AWS Backup Vault config value for the max retention in days"
  type        = string
}

variable "min_vault_retention_days" {
  default     = 30
  description = "AWS Backup Vault config value for the min retention in days"
  type        = string
}