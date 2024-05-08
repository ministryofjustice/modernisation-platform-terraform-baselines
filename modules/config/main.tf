data "aws_region" "current" {}

# Enable AWS Config
resource "aws_config_configuration_recorder" "default" {
  name     = "config"
  role_arn = var.iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "default" {
  name           = "config"
  s3_bucket_name = var.s3_bucket_id
  sns_topic_arn  = aws_sns_topic.default.arn

  snapshot_delivery_properties {
    delivery_frequency = "Three_Hours"
  }

  depends_on = [aws_config_configuration_recorder.default]
}

resource "aws_config_configuration_recorder_status" "default" {

  #checkov:skip=CKV2_AWS_45: "Ensure AWS Config recorder is enabled to record all supported resources - by default AWS config is enabled to record all supported resources"

  name       = "config"
  is_enabled = true
  depends_on = [aws_config_delivery_channel.default]
}

# Create an SNS topic
# AWS-managed account key appropriate for default topic
# tfsec:ignore:aws-sns-topic-encryption-use-cmk
#trivy:ignore:AVD-AWS-0136
resource "aws_sns_topic" "default" {
  name              = "config"
  kms_master_key_id = "alias/aws/sns"
  tags              = var.tags
}

# Configure AWS Config rules
resource "aws_config_config_rule" "access-keys-rotated" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name                        = "access-keys-rotated"
  maximum_execution_frequency = "TwentyFour_Hours"

  input_parameters = jsonencode({
    maxAccessKeyAge : "90"
  })

  source {
    owner             = "AWS"
    source_identifier = "ACCESS_KEYS_ROTATED"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "account-part-of-organizations" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name                        = "account-part-of-organizations"
  maximum_execution_frequency = "TwentyFour_Hours"

  input_parameters = jsonencode({
    MasterAccountId : var.root_account_id
  })

  source {
    owner             = "AWS"
    source_identifier = "ACCOUNT_PART_OF_ORGANIZATIONS"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "cloud-trail-cloud-watch-logs-enabled" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name                        = "cloud-trail-cloud-watch-logs-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_CLOUD_WATCH_LOGS_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "cloud-trail-encryption-enabled" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name                        = "cloud-trail-encryption-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENCRYPTION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "cloud-trail-log-file-validation-enabled" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name                        = "cloud-trail-log-file-validation-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_LOG_FILE_VALIDATION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "cloudtrail-enabled" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name                        = "cloudtrail-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  input_parameters = jsonencode({
    cloudWatchLogsLogGroupArn : "${var.cloudtrail.cloudwatch_log_group_arn}:*",
    s3BucketName : var.cloudtrail.s3_bucket_id,
    snsTopicArn : var.cloudtrail.sns_topic_arn
  })

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "cloudtrail-s3-dataevents-enabled" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name                        = "cloudtrail-s3-dataevents-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "CLOUDTRAIL_S3_DATAEVENTS_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "cloudtrail-security-trail-enabled" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name                        = "cloudtrail-security-trail-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "CLOUDTRAIL_SECURITY_TRAIL_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "iam-group-has-users-check" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name = "iam-group-has-users-check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_GROUP_HAS_USERS_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "iam-no-inline-policy-check" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name = "iam-no-inline-policy-check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_NO_INLINE_POLICY_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "iam-password-policy" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name                        = "iam-password-policy"
  maximum_execution_frequency = "TwentyFour_Hours"

  input_parameters = jsonencode({
    RequireUppercaseCharacters : "true",
    RequireLowercaseCharacters : "true",
    RequireSymbols : "true",
    RequireNumbers : "true",
    MinimumPasswordLength : "8",
    PasswordReusePrevention : "5"
  })

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "iam-root-access-key-check" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name                        = "iam-root-access-key-check"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "iam-user-mfa-enabled" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name                        = "iam-user-mfa-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_MFA_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "iam-user-unused-credentials-check" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name                        = "iam-user-unused-credentials-check"
  maximum_execution_frequency = "TwentyFour_Hours"

  input_parameters = jsonencode({
    maxCredentialUsageAge : "30"
  })

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "mfa-enabled-for-iam-console-access" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name                        = "mfa-enabled-for-iam-console-access"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "multi-region-cloudtrail-enabled" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name                        = "multi-region-cloudtrail-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  input_parameters = jsonencode({
    cloudWatchLogsLogGroupArn : "${var.cloudtrail.cloudwatch_log_group_arn}:*",
    includeManagementEvents : "true",
    readWriteType : "ALL",
    s3BucketName : var.cloudtrail.s3_bucket_id,
    snsTopicArn : var.cloudtrail.sns_topic_arn
  })

  source {
    owner             = "AWS"
    source_identifier = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "required-tags" {
  name = "required-tags"

  input_parameters = jsonencode({
    tag1Key : "business-unit",
    tag2Key : "application",
    tag3Key : "owner",
    tag4Key : "is-production"
  })

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "root-account-mfa-enabled" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name                        = "root-account-mfa-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "s3-account-level-public-access-blocks" {
  count = (var.home_region == data.aws_region.current.name) ? 1 : 0

  name = "s3-account-level-public-access-blocks"

  source {
    owner             = "AWS"
    source_identifier = "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "s3-bucket-public-read-prohibited" {
  name = "s3-bucket-public-read-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "s3-bucket-public-write-prohibited" {
  name = "s3-bucket-public-write-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "s3-bucket-server-side-encryption-enabled" {
  name = "s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "s3-bucket-ssl-requests-only" {
  name = "s3-bucket-ssl-requests-only"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SSL_REQUESTS_ONLY"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "securityhub-enabled" {
  name                        = "securityhub-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "SECURITYHUB_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}

resource "aws_config_config_rule" "sns-encrypted-kms" {
  name = "sns-encrypted-kms"

  source {
    owner             = "AWS"
    source_identifier = "SNS_ENCRYPTED_KMS"
  }

  depends_on = [aws_config_configuration_recorder.default]

  tags = var.tags
}
