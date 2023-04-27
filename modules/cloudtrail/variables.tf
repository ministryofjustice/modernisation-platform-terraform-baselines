# variable "replication_role_arn" {
#   type        = string
#   description = "Role ARN for S3 replication"
# }

variable "cloudtrail_kms_key" {
  description = "Arn of kms key used for cloudtrail logs"
  type        = string
}

variable "cloudtrail_bucket" {
  description = "Name of centralised Cloudtrail bucket"
  type        = string
}
variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map(any)
}

variable "retention_days" {
  default     = 90
  description = "Retention days for logs"
  type        = number
}
