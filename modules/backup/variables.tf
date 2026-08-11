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
  default = "backup-daily-production-retain-30-days"
  type    = string
}

variable "production_backup_selection_name" {
  default = "is-production-true"
  type    = string
}

variable "prod_backup_retention_days" {
  default     = 30
  description = "Production backup plan lifecycle delete_after (days)"
  type        = number
}

variable "non_production_backup_plan_name" {
  default = "backup-daily-non-production-retain-30-days"
  type    = string
}

variable "non_production_backup_selection_name" {
  default = "non-production-backup"
  type    = string
}

variable "production_cold_storage_backup_plan_name" {
  default     = "backup-daily-production-cold-storage-90-days"
  description = "Additional production plan: cold storage lifecycle, 90-day retention"
  type        = string
}

variable "production_cold_storage_backup_selection_name" {
  default     = "is-production-true-cold-storage-90-days"
  description = "Selection for production_cold_storage_backup_plan_name (requires tag backup-cold-storage=true)"
  type        = string
}

variable "non_production_cold_storage_backup_plan_name" {
  default     = "backup-daily-non-production-cold-storage-90-days"
  description = "Additional non-production plan: cold storage lifecycle, 90-day retention"
  type        = string
}

variable "non_production_cold_storage_backup_selection_name" {
  default     = "non-production-backup-cold-storage-90-days"
  description = "Selection for non_production_cold_storage_backup_plan_name (non-production + backup + backup-cold-storage=true)"
  type        = string
}

variable "backup_aws_sns_topic_name" {
  default = "backup_failure_topic"
  type    = string
}

variable "non_prod_backup_retention_days" {
  default     = 30
  description = "AWS Backup variable config for retention days"
  type        = number
}

variable "backup_vault_lock_sns_topic_name" {
  default = "backup_vault_failure_topic"
  type    = string
}

variable "max_vault_retention_days" {
  default     = 90
  description = "AWS Backup Vault lock max retention in days (must be >= cold-storage plan delete_after)"
  type        = number
}

variable "min_vault_retention_days" {
  default     = 7
  description = "AWS Backup Vault config value for the min retention in days"
  type        = number
}

variable "aws_kms_alias_name" {
  default     = "alias/backup-alarms-key-multi-region"
  description = "KMS key name for backup alarms"
  type        = string
}


variable "reduced_preprod_backup_retention" {
  description = "AWS Backup variable, if true, pre prod only retains 7 days of backups"
  type        = bool
}
