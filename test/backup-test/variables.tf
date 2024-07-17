variable "aws_iam_role_backup_name" {
  default = "AWSBackup"
  type    = string
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

variable "non_prod_backup_retention_days" {
  default     = 40
  description = "AWS Backup variable config for retention days"
  type        = number
}

variable "max_vault_retention_days" {
  default     = 30
  description = "AWS Backup Vault config value for the max retention in days"
  type        = number
}

variable "min_vault_retention_days" {
  default     = 30
  description = "AWS Backup Vault config value for the min retention in days"
  type        = number
}

variable "backup_vault_lock_sns_topic_name" {
  default = "backup_vault_failure_topic"
  type    = string
}

variable "aws_kms_alias_name" {
  default     = "alias/backup-alarms-key-multi-region-test"
  description = "KMS key name for backup alarms"
  type        = string
}

variable "reduced_preprod_backup_retention" {
  description = "AWS Backup variable, if true, pre prod only retains 7 days of backups"
  type        = bool
  default     = false
}