variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map(any)
}

variable "enable_unused_access_analyzer" {
  default     = false
  description = "Enable ACCOUNT_UNUSED_ACCESS analyzer to detect unused IAM roles and permissions"
  type        = bool
}

variable "unused_access_analyzer_name" {
  default     = "unused-access-analyzer"
  description = "Name for the unused access analyzer"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.unused_access_analyzer_name)) && length(var.unused_access_analyzer_name) <= 255
    error_message = "Analyzer name must contain only alphanumeric characters, hyphens, and underscores, and be 255 characters or less."
  }
}

variable "unused_access_age_days" {
  default     = 90
  description = "Number of days after which access is considered unused (1-365)"
  type        = number

  validation {
    condition     = var.unused_access_age_days >= 1 && var.unused_access_age_days <= 365 && floor(var.unused_access_age_days) == var.unused_access_age_days
    error_message = "Unused access age must be a whole number between 1 and 365 days."
  }
}
