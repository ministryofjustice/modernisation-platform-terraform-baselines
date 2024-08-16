output "sns_topic_arn" {
  value       = aws_sns_topic.default.arn
  description = "Config SNS topic ARN"
}

output "default_config_configuration_recorder_arn" {
  value       = aws_config_configuration_recorder.default.name
  description = "The ARN of the  config configuration recorder for default"
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
  description = "The ARN of sns topic for default"
}

output "access_keys_rotated_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.access-keys-rotated[0].arn
  description = "The ARN of the config config rule for access keys rotated"
}

  output "account-part-of-organizations_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.account-part-of-organizations[0].arn
  description = "The ARN of the config config rule for account part of organizations"
}

  output "cloud-trail-cloud-watch-logs-enabled_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.cloud-trail-cloud-watch-logs-enabled[0].arn
  description = "The ARN of the config config rule for cloud trail cloud watch logs enabled"
}

  output "cloud-trail-encryption-enabled_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.cloud-trail-encryption-enabled[0].arn
  description = "The ARN of the config config rule for cloud trail encryption enable"
}

  output "cloud-trail-log-file-validation-enabled_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.cloud-trail-log-file-validation-enabled[0].arn
  description = "The ARN of the config config rule for cloud trail log file validation enabled"
}

  output "cloudtrail-enabled_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.cloudtrail-enabled[0].arn
  description = "The ARN of the config config rule for cloudtrail enabled"
}

  output "cloudtrail-s3-dataevents-enabled_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.cloudtrail-s3-dataevents-enabled[0].arn
  description = "The ARN of the config config rule for cloudtrail s3 dataevents enabled"
}

  output "cloudtrail-security-trail-enabled_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.cloudtrail-security-trail-enabled[0].arn
  description = "The ARN of the config config rule for cloudtrail security trail enabled"
}

  output "iam-group-has-users-check_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.iam-group-has-users-check[0].arn
  description = "The ARN of the config config rule for iam group has users check"
}

  output "iam-no-inline-policy-check_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.iam-no-inline-policy-check[0].arn
  description = "The ARN of the config config rule for iam no inline policy check"
}

  output "iam-password-policy_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.iam-password-policy[0].arn
  description = "The ARN of the config config rule for iam password policy"
}

  output "iam-root-access-key-check_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.iam-root-access-key-check[0].arn
  description = "The ARN of the config config rule for iam root access key check"
}

  output "iam-user-mfa-enabled_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.iam-user-mfa-enabled[0].arn
  description = "The ARN of the config config rule for iam user mfa enabled"
}

  output "iam-user-unused-credentials-check_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.iam-user-unused-credentials-check[0].arn
  description = "The ARN of the config config rule for iam user unused credentials check"
}

  output "mfa-enabled-for-iam-console-access_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.mfa-enabled-for-iam-console-access[0].arn
  description = "The ARN of the config config rule for mfa enabled for iam console access"
}

  output "multi-region-cloudtrail-enabled_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.multi-region-cloudtrail-enabled[0].arn
  description = "The ARN of the config config rule for multi region cloudtrail enabled"
}

  output "required-tags_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.required-tags.arn
  description = "The ARN of the config config rule for required tags"
}

  output "root-account-mfa-enabled_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.root-account-mfa-enabled[0].arn
  description = "The ARN of the config config rule for root account mfa enabled"
}

  output "s3-account-level-public-access-blocks_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.s3-account-level-public-access-blocks[0].arn
  description = "The ARN of the config config rule for s3 account level public access blocks"
}

  output "s3-bucket-public-read-prohibited_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.s3-bucket-public-read-prohibited.arn
  description = "The ARN of the config config rule for s3 bucket public read prohibited"
}

  output "s3-bucket-public-write-prohibited_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.s3-bucket-public-write-prohibited.arn
  description = "The ARN of the config config rule for s3 bucket public write prohibited"
}

  output "s3-bucket-server-side-encryption-enabled_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.s3-bucket-server-side-encryption-enabled.arn
  description = "The ARN of the config config rule for s3 bucket server side encryption enabled"
}

  output "s3-bucket-ssl-requests-only_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.s3-bucket-ssl-requests-only.arn
  description = "The ARN of the config config rule for s3 bucket ssl requests only"
}

  output "securityhub-enabled_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.securityhub-enabled.arn
  description = "The ARN of the config config rule for securityhub enabled"
}

  output "sns-encrypted-kms_aws_config_config_rule_arn" {
  value       = aws_config_config_rule.sns-encrypted-kms.arn
  description = "The ARN of the config config rule for sns encrypted kms"
}