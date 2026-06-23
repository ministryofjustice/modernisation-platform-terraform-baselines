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
  description = "A PagerDuty integration key for high priority alerts that do not trigger on-call"
  type        = string
}

variable "enabled_ssm_baseline_regions" {
  description = "Regions where SSM baseline controls are enforced."
  type        = list(string)
  default     = ["eu-west-1", "eu-west-2", "eu-west-3", "eu-central-1", "us-east-1"]
}

variable "enable_session_manager_logging" {
  description = "Enable central Session Manager transcript logging baseline."
  type        = bool
  default     = false
}

variable "session_manager_logging_regions" {
  description = "Regions where central Session Manager transcript logging is enabled. The wider SSM baseline can still run in other regions."
  type        = set(string)
  default     = ["eu-west-1", "eu-west-2"]
}

variable "session_manager_log_kms_key_id" {
  description = "Optional KMS key ARN or ID used to encrypt central Session Manager transcript log groups."
  type        = string
  default     = null
}

variable "session_manager_idle_timeout_minutes" {
  description = "Idle timeout in minutes for central Session Manager shell sessions."
  type        = number
  default     = 60
}

variable "session_manager_logging_excluded_applications" {
  description = "Applications excluded from central Session Manager transcript logging because they already manage it through the environments repo baseline preset."
  type        = set(string)
  default = [
    "hmpps-oem",
    "nomis-data-hub",
    "corporate-staff-rostering",
    "nomis",
    "oasys-national-reporting",
    "oasys",
    "nomis-combined-reporting",
    "hmpps-domain-services",
    "planetfm",
    "prison-retail",
  ]
}

# The following deal with the provision of slack alerts for CRITICAL and other levels for the CORE accounts only.
variable "securityhub_slack_alerts_pagerduty_integration_key" {
  default     = ""
  description = "A PagerDuty integration key for Security Hub High Priority Alerts"
  type        = string
}

variable "enable_securityhub_slack_alerts" {
  description = "Accounts that have Security Hub Alerts Enabled. Typically covers MP Core Accounts."
  type        = bool
}

variable "securityhub_slack_alerts_scope" {
  description = "List of the criticality levels covered by the security hub alerts. Minimum is CRITICAL"
  type        = list(string)
  default     = ["CRITICAL"]
}

variable "enable_securityhub_event_forwarding" {
  description = "When true, forward qualifying Security Hub findings to the central EventBridge bus"
  type        = bool
  default     = false
}

variable "securityhub_central_event_bus_arn" {
  description = "ARN of the central EventBridge event bus that receives forwarded findings"
  type        = string
  default     = ""
}

variable "securityhub_forwarding_scope" {
  description = "List of Security Hub severity labels that should be forwarded to the central EventBridge bus."
  default     = ["CRITICAL", "HIGH"]
}
