variable "replication_role_arn" {
  type        = string
  description = "Role ARN for S3 replication"
}

 variable "cloudtrail_kms_key" {
   description = "Arn of kms key used for cloudtrail logs"
   type        = string
 }

variable "cloudtrail_bucket" {
  description = "Name of centralised Cloudtrail bucket"
  type        = string
}

variable "enable_cloudtrail_s3_mgmt_events" {
  type        = bool
  default     = true
  description = "Enable CT Object-level logging, defaults to true"
}

variable "retention_days" {
  default     = 400
  description = "Retention days for logs"
  type        = number
}

variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map(any)
}