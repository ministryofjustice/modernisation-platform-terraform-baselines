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

variable "bucket_name" {
  default = "cloudtrail_test_bucket"
  type = string
}

variable "aws_kms_alias_name" {
  default     = "alias/cloudtrail-key-test"
  description = "KMS key name for cloudtrail"
  type        = string
}

variable "enable_cloudtrail_s3_mgmt_events" {
  type        = bool
  default     = true
  description = "Enable CT Object-level logging, defaults to true"
}

variable "cloudtrail_bucket" {
  description = "Name of centralised Cloudtrail bucket"
  type        = string
}