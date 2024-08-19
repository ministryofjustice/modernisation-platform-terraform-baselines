data "aws_iam_role" "config" {
  name = "AWSConfig"  # Ensure this matches the IAM role name in AWS
}

module "config-test" {
  source                                                    = "../../modules/config"
  cloudtrail                                                = var.cloudtrail
  root_account_id                                           = var.root_account_id
  iam_role_arn                                              = data.aws_iam_role.config.arn
  s3_bucket_id                                              = var.s3_bucket_id
  home_region                                               = var.home_region
  tags                                                      = var.tags
  config_name                                               = var.config_name
  config_rule_access_keys_rotated_name                      = var.config_rule_access_keys_rotated_name
  config_rule_account_part_of_organizations_name            = var.config_rule_account_part_of_organizations_name
  config_rule_cloud_trail_cloud_watch_logs_enabled_name     = var.config_rule_cloud_trail_cloud_watch_logs_enabled_name
  config_rule_cloud_trail_encryption_enabled_name           = var.config_rule_cloud_trail_encryption_enabled_name
  config_rule_cloud_trail_log_file_validation_enabled_name  = var.config_rule_cloud_trail_log_file_validation_enabled_name
  config_rule_cloudtrail_enabled_name                       = var.config_rule_cloudtrail_enabled_name
  config_rule_cloudtrail_s3_dataevents_enabled_name         = var.config_rule_cloudtrail_s3_dataevents_enabled_name
  config_rule_cloudtrail_security_trail_enabled_name        = var.config_rule_cloudtrail_security_trail_enabled_name
  config_rule_iam_group_has_users_check_name                = var.config_rule_iam_group_has_users_check_name
  config_rule_iam_no_inline_policy_check_name               = var.config_rule_iam_no_inline_policy_check_name
  config_rule_iam_password_policy_name                      = var.config_rule_iam_password_policy_name
  config_rule_iam_root_access_key_check_name                = var.config_rule_iam_root_access_key_check_name
  config_rule_iam_user_mfa_enabled_name                     = var.config_rule_iam_user_mfa_enabled_name
  config_rule_iam_user_unused_credentials_check_name        = var.config_rule_iam_user_unused_credentials_check_name
  config_rule_mfa_enabled_for_iam_console_access_name       = var.config_rule_mfa_enabled_for_iam_console_access_name
  config_rule_multi_region_cloudtrail_enabled_name          = var.config_rule_multi_region_cloudtrail_enabled_name
  config_rule_required_tags_name                            = var.config_rule_required_tags_name
  config_rule_root_account_mfa_enabled_name                 = var.config_rule_root_account_mfa_enabled_name
  config_rule_s3_account_level_public_access_blocks_name    = var.config_rule_s3_account_level_public_access_blocks_name
  config_rule_s3_bucket_public_read_prohibited_name         = var.config_rule_s3_bucket_public_read_prohibited_name
  config_rule_s3_bucket_public_write_prohibited_name        = var.config_rule_s3_bucket_public_write_prohibited_name
  config_rule_s3_bucket_server_side_encryption_enabled_name = var.config_rule_s3_bucket_server_side_encryption_enabled_name
  config_rule_s3_bucket_ssl_requests_only_name              = var.config_rule_s3_bucket_ssl_requests_only_name
  config_rule_securityhub_enabled_name                      = var.config_rule_securityhub_enabled_name
  config_rule_sns_encrypted_kms_name                        = var.config_rule_sns_encrypted_kms_name
  }
