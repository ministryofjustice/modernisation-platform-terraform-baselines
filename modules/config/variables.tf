variable "cloudtrail" {
  description = "CloudTrail variables for: SNS topic, AWS S3 bucket, and CloudWatch Log Group to configure the Config rule to check it's configured correctly"
  type        = map(any)
}

variable "root_account_id" {
  description = "The AWS Organisations root account ID that this account should be part of"
  type        = string
}

variable "current_account_id" {
  description = "value of the current account ID"
  type        = string
}

variable "iam_role_arn" {
  description = "IAM role ARN for the AWS Config service role"
  type        = string
}

variable "s3_bucket_id" {
  description = "S3 bucket ID for AWS Config to publish to"
  type        = string
}

variable "home_region" {
  type        = string
  description = "Region to enable AWS Config rules for global resources, such as IAM. Currently taken from the calling region"
}

variable "sns_topic_key" {
  type        = string
  description = "value of the multi-region SNS topic key ARN"
}

variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map(any)
}
