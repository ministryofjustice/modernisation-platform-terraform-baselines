output "sns_topic_arn" {
  value       = aws_sns_topic.default.arn
  description = "Config SNS topic ARN"
}

output "default_config_configuration_recorder_arn" {
  value       = aws_config_configuration_recorder.default.name
  description = "The ARN of the config configuration recorder for default"
}

output "default_aws_config_delivery_channel_arn" {
  value       = aws_config_delivery_channel.default.name
  description = "The ARN of the config channel for default"
}

output "default_aws_config_configuration_recorder_status_arn" {
  value       = aws_config_configuration_recorder_status.default.name
  description = "The ARN of the config configuration recorder status for default"
}

output "default_aws_sns_topic_arn" {
  value       = aws_sns_topic.default.arn
  description = "The ARN of SNS topic for default"
}

output "access_keys_rotated_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.access-keys-rotated) > 0 ? aws_config_config_rule.access-keys-rotated[0].arn : null
  description = "The ARN of the config rule for access keys rotated"
}

output "account_part_of_organizations_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.account-part-of-organizations) > 0 ? aws_config_config_rule.account-part-of-organizations[0].arn : null
  description = "The ARN of the config rule for account part of organizations"
}

output "cloud_trail_cloud_watch_logs_enabled_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.cloud-trail-cloud-watch-logs-enabled) > 0 ? aws_config_config_rule.cloud-trail-cloud-watch-logs-enabled[0].arn : null
  description = "The ARN of the config rule for CloudTrail CloudWatch logs enabled"
}

output "cloud_trail_encryption_enabled_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.cloud-trail-encryption-enabled) > 0 ? aws_config_config_rule.cloud-trail-encryption-enabled[0].arn : null
  description = "The ARN of the config rule for CloudTrail encryption enabled"
}

output "cloud_trail_log_file_validation_enabled_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.cloud-trail-log-file-validation-enabled) > 0 ? aws_config_config_rule.cloud-trail-log-file-validation-enabled[0].arn : null
  description = "The ARN of the config rule for CloudTrail log file validation enabled"
}

output "cloudtrail_enabled_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.cloudtrail-enabled) > 0 ? aws_config_config_rule.cloudtrail-enabled[0].arn : null
  description = "The ARN of the config rule for CloudTrail enabled"
}

output "cloudtrail_s3_dataevents_enabled_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.cloudtrail-s3-dataevents-enabled) > 0 ? aws_config_config_rule.cloudtrail-s3-dataevents-enabled[0].arn : null
  description = "The ARN of the config rule for CloudTrail S3 data events enabled"
}

output "cloudtrail_security_trail_enabled_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.cloudtrail-security-trail-enabled) > 0 ? aws_config_config_rule.cloudtrail-security-trail-enabled[0].arn : null
  description = "The ARN of the config rule for CloudTrail security trail enabled"
}

output "iam_group_has_users_check_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.iam-group-has-users-check) > 0 ? aws_config_config_rule.iam-group-has-users-check[0].arn : null
  description = "The ARN of the config rule for IAM group has users check"
}

output "iam_no_inline_policy_check_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.iam-no-inline-policy-check) > 0 ? aws_config_config_rule.iam-no-inline-policy-check[0].arn : null
  description = "The ARN of the config rule for IAM no inline policy check"
}

output "iam_password_policy_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.iam-password-policy) > 0 ? aws_config_config_rule.iam-password-policy[0].arn : null
  description = "The ARN of the config rule for IAM password policy"
}

output "iam_root_access_key_check_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.iam-root-access-key-check) > 0 ? aws_config_config_rule.iam-root-access-key-check[0].arn : null
  description = "The ARN of the config rule for IAM root access key check"
}

output "iam_user_mfa_enabled_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.iam-user-mfa-enabled) > 0 ? aws_config_config_rule.iam-user-mfa-enabled[0].arn : null
  description = "The ARN of the config rule for IAM user MFA enabled"
}

output "iam_user_unused_credentials_check_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.iam-user-unused-credentials-check) > 0 ? aws_config_config_rule.iam-user-unused-credentials-check[0].arn : null
  description = "The ARN of the config rule for IAM user unused credentials check"
}

output "mfa_enabled_for_iam_console_access_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.mfa-enabled-for-iam-console-access) > 0 ? aws_config_config_rule.mfa-enabled-for-iam-console-access[0].arn : null
  description = "The ARN of the config rule for MFA enabled for IAM console access"
}

output "multi_region_cloudtrail_enabled_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.multi-region-cloudtrail-enabled) > 0 ? aws_config_config_rule.multi-region-cloudtrail-enabled[0].arn : null
  description = "The ARN of the config rule for multi-region CloudTrail enabled"
}

output "required_tags_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.required-tags.arn
  description = "The ARN of the config rule for required tags"
}

output "root_account_mfa_enabled_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.root-account-mfa-enabled) > 0 ? aws_config_config_rule.root-account-mfa-enabled[0].arn : null
  description = "The ARN of the config rule for root account MFA enabled"
}

output "s3_account_level_public_access_blocks_aws_config_config_rule_arn" {
  value       = length(aws_config_config_rule.s3-account-level-public-access-blocks) > 0 ? aws_config_config_rule.s3-account-level-public-access-blocks[0].arn : null
  description = "The ARN of the config rule for S3 account-level public access blocks"
}

output "s3_bucket_public_read_prohibited_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.s3-bucket-public-read-prohibited.arn
  description = "The ARN of the config rule for S3 bucket public read prohibited"
}

output "s3_bucket_public_write_prohibited_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.s3-bucket-public-write-prohibited.arn
  description = "The ARN of the config rule for S3 bucket public write prohibited"
}

output "s3_bucket_server_side_encryption_enabled_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.s3-bucket-server-side-encryption-enabled.arn
  description = "The ARN of the config rule for S3 bucket server-side encryption enabled"
}

output "s3_bucket_ssl_requests_only_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.s3-bucket-ssl-requests-only.arn
  description = "The ARN of the config rule for S3 bucket SSL requests only"
}

output "securityhub_enabled_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.securityhub-enabled.arn
  description = "The ARN of the config rule for SecurityHub enabled"
}

output "sns_encrypted_kms_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.sns-encrypted-kms.arn
  description = "The ARN of the config rule for SNS encrypted KMS"
}



