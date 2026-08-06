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
  default     = 20

  validation {
    condition     = var.session_manager_idle_timeout_minutes >= 1 && var.session_manager_idle_timeout_minutes <= 60
    error_message = "session_manager_idle_timeout_minutes must be between 1 and 60."
  }
}

variable "tags" {
  description = "Tags to apply to resources that support tagging."
  type        = map(any)
  default     = {}
}
