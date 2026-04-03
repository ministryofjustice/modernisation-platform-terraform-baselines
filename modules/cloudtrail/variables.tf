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

variable "enable_cloudtrail_s3_mgmt_events" {
  type        = bool
  default     = true
  description = "Enable CT Object-level logging, defaults to true"
}

variable "enable_cloudtrail_limit_readonly_bucket_events" {
  type        = bool
  default     = false
  description = "Disables readonly events in cloudtrail for specific buckets"
}

variable "cloudtrail_limit_readonly_bucket_arns" {
  type        = list(string)
  default     = []
  description = "List of S3 object ARNs (e.g. arn:aws:s3:::bucket-name/) for which only write data events should be logged when enable_cloudtrail_limit_readonly_bucket_events is true"
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

variable "cloudtrail_name" {
  description = "The name of the CloudTrail"
  type        = string
  default     = "cloudtrail"
}

variable "cloudtrail_policy_name" {
  description = "The name of the IAM policy for CloudTrail"
  type        = string
  default     = "AWSCloudTrailPolicy"
}