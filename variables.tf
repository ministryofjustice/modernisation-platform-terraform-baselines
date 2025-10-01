variable "cloudtrail_kms_key" {
  description = "Arn of kms key used for cloudtrail logs"
  type        = string
}

variable "enable_cloudtrail_s3_mgmt_events" {
  type        = bool
  default     = true
  description = "Enable CT Object-level logging, defaults to true"
}

variable "enabled_access_analyzer_regions" {
  default     = []
  description = "Regions to enable IAM Access Analyzer in"
  type        = list(string)
}

variable "enabled_backup_regions" {
  default     = []
  description = "Regions to enable AWS Backup in"
  type        = list(string)
}

variable "enabled_config_regions" {
  default     = []
  description = "Regions to enable AWS Config in"
  type        = list(string)
}

variable "enabled_ebs_encryption_regions" {
  default     = []
  description = "Regions to enable EBS encryption in"
  type        = list(string)
}

variable "enabled_guardduty_regions" {
  default     = []
  description = "Regions to enable GuardDuty in"
  type        = list(string)
}

variable "enabled_securityhub_regions" {
  default     = []
  description = "Regions to enable SecurityHub in"
  type        = list(string)
}

variable "root_account_id" {
  type        = string
  description = "The AWS Organisations root account ID that this account should be part of"
}

variable "current_account_id" {
  description = "value of the current account ID"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map(any)
}

variable "enabled_imdsv2_regions" {
  default     = []
  description = "Regions to enable IMDSv2 in"
  type        = list(string)
}

variable "reduced_preprod_backup_retention" {
  description = "AWS Backup variable, if true, pre prod only retains 7 days of backups"
  type        = bool
}

variable "pagerduty_integration_key" {
  default     = ""
  description = "A PagerDuty integration key to pass into a PagerDuty integration"
  type        = string
}

variable "high_priority_pagerduty_integration_key" {
  default     = ""
  description = "A PagerDuty integration key for high priority alerts"
  type        = string
}
variable "enabled_ssm_baseline_regions" {
  description = "Regions where SSM baseline controls are enforced."
  type        = list(string)
  default     = ["eu-west-1", "eu-west-2", "eu-west-3", "eu-central-1", "us-east-1"]
}