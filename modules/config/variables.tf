variable "cloudtrail" {
  description = "CloudTrail variables for: SNS topic, AWS S3 bucket, and CloudWatch Log Group to configure the Config rule to check it's configured correctly"
  type        = map
}

variable "root_account_id" {
  description = "The AWS Organisations root account ID that this account should be part of"
  type        = string
}

variable "tags" {}
