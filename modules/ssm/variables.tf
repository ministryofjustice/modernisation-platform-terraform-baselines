variable "enable_session_manager_logging" {
  description = "Enable Session Manager transcript logging to CloudWatch Logs."
  type        = bool
  default     = false
}

variable "session_manager_log_retention_in_days" {
  description = "Retention period in days for Session Manager transcript logs."
  type        = number
  default     = 400
}

variable "session_manager_log_kms_key_id" {
  description = "Optional KMS key ARN or ID used to encrypt the Session Manager CloudWatch log group."
  type        = string
  default     = null
}

variable "session_manager_idle_timeout_minutes" {
  description = "Idle timeout in minutes for Session Manager shell sessions."
  type        = number
  default     = 60
}

variable "create_session_manager_logging_iam_policy" {
  description = "Create the IAM policy that allows EC2 instance roles to write Session Manager transcript logs to CloudWatch Logs. This should only be enabled once per account."
  type        = bool
  default     = false
}

variable "session_manager_logging_regions" {
  description = "Regions where Session Manager transcript log groups are created. Used to scope the supporting IAM policy."
  type        = set(string)
  default     = ["eu-west-1", "eu-west-2"]
}

variable "tags" {
  description = "Tags to apply to resources that support tagging."
  type        = map(any)
  default     = {}
}
