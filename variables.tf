variable "baseline_assume_role" {
  type        = bool
  description = "Whether or not a role needs to be assumed to manage these resources"
  default     = false
}

variable "baseline_directory" {
  type        = string
  description = "Directory to put this module's generated files into"
}

variable "baseline_provider_key" {
  type        = string
  description = "A unique provider key to use for provider definitions"
}

variable "tags" {
  type        = map
  default     = {}
  description = "Tags to apply to resources, where applicable"
}
