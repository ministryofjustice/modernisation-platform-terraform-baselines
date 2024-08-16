variable "cloudtrail" {
  description = "CloudTrail variables for: SNS topic, AWS S3 bucket, and CloudWatch Log Group to configure the Config rule to check it's configured correctly"
  type        = map(any)
   default     = {}

}

variable "root_account_id" {
  description = "The AWS Organisations root account ID that this account should be part of"
  type        = string
  default     = ""
}

variable "iam_role_arn" {
  description = "IAM role ARN for the AWS Config service role"
  type        = string
  default     = ""
}

variable "s3_bucket_id" {
  description = "S3 bucket ID for AWS Config to publish to"
  type        = string
  default     = ""

}

variable "home_region" {
  type        = string
  default     = ""
  description = "Region to enable AWS Config rules for global resources, such as IAM. Currently taken from the calling region"
}

variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map(any)
}

variable "config_name" {
  type        = string
  default     = "config"
}

variable "config_rule_access_keys_rotated_name" {
  type        = string
  default     = "access-keys-rotated"
}

variable "config_rule_account_part_of_organizations_name" {
  type        = string
  default     = "account-part-of-organizations"
}

variable "config_rule_cloud_trail_cloud_watch_logs_enabled_name" {
  description = "Name for the AWS Config rule that checks if CloudTrail is integrated with CloudWatch Logs"
  type        = string
  default     = "cloud-trail-cloud-watch-logs-enabled"
}

variable "config_rule_cloud_trail_encryption_enabled_name" {
  type        = string
  default     = "cloud-trail-encryption-enabled"
}

variable "config_rule_cloud_trail_log_file_validation_enabled_name" {
  type        = string
  default     = "cloud-trail-log-file-validation-enabled"
}
variable "config_rule_cloudtrail_enabled_name" {
  type        = string
  default     = "cloudtrail-enabled"
}

variable "config_rule_cloudtrail_s3_dataevents_enabled_name" {
  type        = string
  default     = "cloudtrail-s3-dataevents-enabled"
}

variable "config_rule_cloudtrail_security_trail_enabled_name" {
  type        = string
  default     = "cloudtrail-security-trail-enabled"
}

variable "config_rule_iam_group_has_users_check_name" {
  type        = string
  default     = "iam-group-has-users-check"
}

variable "config_rule_iam_no_inline_policy_check_name" {
  type        = string
  default     = "iam-no-inline-policy-check"
}

variable "config_rule_iam_password_policy_name" {
  type        = string
  default     = "iam-password-policy"
}

variable "config_rule_iam_root_access_key_check_name" {
  description = "Name for the AWS Config rule that checks if IAM root access keys are present"
  type        = string
  default     = "iam-root-access-key-check"
}

variable "config_rule_iam_user_mfa_enabled_name" {
  type        = string
  default     = "iam-user-mfa-enabled"
}

variable "config_rule_iam_user_unused_credentials_check_name" {
  type        = string
  default     = "iam-user-unused-credentials-check"
}

variable "config_rule_mfa_enabled_for_iam_console_access_name" {
  type        = string
  default     = "mfa-enabled-for-iam-console-access"
}

variable "config_rule_multi_region_cloudtrail_enabled_name" {
  type        = string
  default     = "multi-region-cloudtrail-enabled"
}

variable "config_rule_required_tags_name" {
  type        = string
  default     = "required-tags"
}

variable "config_rule_root_account_mfa_enabled_name" {
  type        = string
  default     = "root-account-mfa-enabled"
}

variable "config_rule_s3_account_level_public_access_blocks_name" {
  type        = string
  default     = "s3-account-level-public-access-blocks"
}

variable "config_rule_s3_bucket_public_read_prohibited_name" {
  type        = string
  default     = "s3-bucket-public-read-prohibited"
}

variable "config_rule_s3_bucket_public_write_prohibited_name" {
  type        = string
  default     = "s3-bucket-public-write-prohibited"
}

variable "config_rule_s3_bucket_server_side_encryption_enabled_name" {
  type        = string
  default     = "s3-bucket-server-side-encryption-enabled"
}

variable "config_rule_s3_bucket_ssl_requests_only_name" {
  type        = string
  default     = "s3-bucket-ssl-requests-only"
}

variable "config_rule_securityhub_enabled_name" {
  type        = string
  default     = "securityhub-enabled"
}

variable "config_rule_sns_encrypted_kms_name" {
  description = "Name for the AWS Config rule that checks if SNS topics are encrypted with KMS"
  type        = string
  default     = "sns-encrypted-kms"
}