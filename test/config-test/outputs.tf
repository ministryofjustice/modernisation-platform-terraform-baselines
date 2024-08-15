output "sns_topic_arns" {
  value = {
    default                          = module.config.sns_topic_arn
    default_aws                      = module.config.default_aws_sns_topic_arn
    sns_encrypted_kms                = module.config.sns_encrypted_kms_aws_config_config_rule_arn
  }
  description = "ARNs of SNS topics"
}

output "config_configuration_recorder_arns" {
  value = {
    default                          = module.config.default_config_configuration_recorder_arn
    status                           = module.config.default_aws_config_configuration_recorder_status_arn
  }
  description = "ARNs of Config configuration recorders"
}

output "config_delivery_channel_arn" {
  value = module.config.default_aws_config_delivery_channel_arn
  description = "The ARN of the Config delivery channel"
}

output "config_rule_arns" {
  value = {
    access_keys_rotated                = module.config.access_keys_rotated_aws_config_config_rule_arn
    account_part_of_organizations      = module.config.account_part_of_organizations_aws_config_config_rule_arn
    cloud_trail_cloud_watch_logs       = module.config.cloud_trail_cloud_watch_logs_enabled_aws_config_config_rule_arn
    cloud_trail_encryption             = module.config.cloud_trail_encryption_enable_aws_config_config_rule_arn
    cloud_trail_log_file_validation    = module.config.cloud_trail_log_file_validation_enabled_aws_config_config_rule_arn
    cloudtrail_enabled                 = module.config.cloudtrail_enabled_aws_config_config_rule_arn
    cloudtrail_s3_dataevents           = module.config.cloudtrail_s3_dataevents_enabled_aws_config_config_rule_arn
    cloudtrail_security_trail          = module.config.cloudtrail_security_trail_enabled_aws_config_config_rule_arn
    iam_group_has_users_check          = module.config.iam_group_has_users_check_aws_config_config_rule_arn
    iam_no_inline_policy_check         = module.config.iam_no_inline_policy_check_aws_config_config_rule_arn
    iam_password_policy                = module.config.iam_password_policy_aws_config_config_rule_arn
    iam_root_access_key_check          = module.config.iam_root_access_key_check_aws_config_config_rule_arn
    iam_user_mfa_enabled               = module.config.iam_user_mfa_enabled_aws_config_config_rule_arn
    iam_user_unused_credentials        = module.config.iam_user_unused_credentials_check_aws_config_config_rule_arn
    mfa_enabled_for_console_access     = module.config.mfa_enabled_for_iam_console_access_aws_config_config_rule_arn
    multi_region_cloudtrail            = module.config.multi_region_cloudtrail_enabled_aws_config_config_rule_arn
    required_tags                      = module.config.required_tags_aws_config_config_rule_arn
    root_account_mfa_enabled           = module.config.root_account_mfa_enabled_aws_config_config_rule_arn
    s3_account_level_public_access     = module.config.s3_account_level_public_access_blocks_aws_config_config_rule_arn
    s3_bucket_public_read_prohibited   = module.config.s3_bucket_public_read_prohibited_aws_config_config_rule_arn
    s3_bucket_public_write_prohibited  = module.config.s3_bucket_public_write_prohibited_aws_config_config_rule_arn
    s3_bucket_server_side_encryption   = module.config.s3_bucket_server_side_encryption_enabled_aws_config_config_rule_arn
    s3_bucket_ssl_requests_only        = module.config.s3_bucket_ssl_requests_only_aws_config_config_rule_arn
    securityhub_enabled                = module.config.securityhub_enabled_aws_config_config_rule_arn
  }
  description = "ARNs of Config rules"
}
