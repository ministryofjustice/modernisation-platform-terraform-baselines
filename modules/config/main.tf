## This file is automatically generated based on what regions are enabled in an AWS account and what regions Config is available in.

data "aws_caller_identity" "current" {}

# AWS Config: Configure a role using eu-west-2
resource "aws_iam_role" "config" {
  name               = "AWSConfig"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = var.tags
}

data "aws_iam_policy_document" "assume_role_policy" {
  version = "2012-10-17"
  statement {
    sid     = "AllowAWSConfigAssumeRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "managed_policy" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

# AWS Config: Configure an S3 bucket in eu-west-2
resource "aws_s3_bucket" "config" {
  bucket_prefix = "config-"
  acl           = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "config" {
  bucket                  = aws_s3_bucket.config.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "config_bucket" {
  bucket = aws_s3_bucket.config.bucket
  policy = data.aws_iam_policy_document.config_bucket.json
}

data "aws_iam_policy_document" "config_bucket" {
  version   = "2012-10-17"
  policy_id = "ConfigBucketPolicy"

  statement {
    sid       = "AWSConfigBucketPermissionsCheck"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.config.arn]

    principals {
      identifiers = ["config.amazonaws.com"]
      type        = "Service"
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }

  statement {
    sid     = "AWSConfigBucketDelivery"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.config.arn}/*"
    ]

    principals {
      identifiers = ["config.amazonaws.com"]
      type        = "Service"
    }

    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }

  statement {
    sid     = "Require SSL"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "${aws_s3_bucket.config.arn}/*"
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

# Enable Config in each available region
resource "aws_config_configuration_recorder" "aws-eu-west-2" {
  name     = "config"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "aws-eu-west-2" {
  name           = "config"
  s3_bucket_name = aws_s3_bucket.config.id
  s3_key_prefix  = "aws-eu-west-2"
  sns_topic_arn  = aws_sns_topic.aws-eu-west-2.arn

  snapshot_delivery_properties {
    delivery_frequency = "Three_Hours"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]
}

resource "aws_config_configuration_recorder_status" "aws-eu-west-2" {
  name       = "config"
  is_enabled = true
  depends_on = [aws_config_delivery_channel.aws-eu-west-2]
}

# Create an SNS topic for each region
resource "aws_sns_topic" "aws-eu-west-2" {
  name = "config"
  tags = var.tags
}

resource "aws_sns_topic_policy" "aws-eu-west-2" {
  arn    = aws_sns_topic.aws-eu-west-2.arn
  policy = data.aws_iam_policy_document.sns_topic_policy-aws-eu-west-2.json
}

data "aws_iam_policy_document" "sns_topic_policy-aws-eu-west-2" {
  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [data.aws_caller_identity.current.account_id]
    }
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [aws_sns_topic.aws-eu-west-2.arn]
    sid       = "DefaultSNSPolicy"
  }

  statement {
    actions = ["SNS:Publish"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.config.arn]
    }
    resources = [aws_sns_topic.aws-eu-west-2.arn]
    sid       = "AWSConfigSNSPolicyAllowRole"
  }
}

# Configure AWS Config rules
resource "aws_config_config_rule" "access-keys-rotated" {
  name                        = "access-keys-rotated"
  maximum_execution_frequency = "TwentyFour_Hours"

  input_parameters = jsonencode({
    maxAccessKeyAge : "90"
  })

  source {
    owner             = "AWS"
    source_identifier = "ACCESS_KEYS_ROTATED"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "account-part-of-organizations" {
  name                        = "account-part-of-organizations"
  maximum_execution_frequency = "TwentyFour_Hours"

  input_parameters = jsonencode({
    MasterAccountId : var.root_account_id
  })

  source {
    owner             = "AWS"
    source_identifier = "ACCOUNT_PART_OF_ORGANIZATIONS"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "cloud-trail-cloud-watch-logs-enabled" {
  name                        = "cloud-trail-cloud-watch-logs-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_CLOUD_WATCH_LOGS_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "cloud-trail-encryption-enabled" {
  name                        = "cloud-trail-encryption-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENCRYPTION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "cloud-trail-log-file-validation-enabled" {
  name                        = "cloud-trail-log-file-validation-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_LOG_FILE_VALIDATION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "cloudtrail-enabled" {
  name                        = "cloudtrail-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  input_parameters = jsonencode({
    cloudWatchLogsLogGroupArn : var.cloudtrail.cloudwatch_log_group_arn,
    s3BucketName : var.cloudtrail.s3_bucket_id,
    snsTopicArn : var.cloudtrail.sns_topic_arn
  })

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "cloudtrail-s3-dataevents-enabled" {
  name                        = "cloudtrail-s3-dataevents-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "CLOUDTRAIL_S3_DATAEVENTS_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "cloudtrail-security-trail-enabled" {
  name                        = "cloudtrail-security-trail-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "CLOUDTRAIL_SECURITY_TRAIL_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "iam-group-has-users-check" {
  name = "iam-group-has-users-check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_GROUP_HAS_USERS_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "iam-no-inline-policy-check" {
  name = "iam-no-inline-policy-check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_NO_INLINE_POLICY_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "iam-password-policy" {
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

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "iam-root-access-key-check" {
  name                        = "iam-root-access-key-check"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "iam-user-mfa-enabled" {
  name                        = "iam-user-mfa-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_MFA_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "iam-user-unused-credentials-check" {
  name                        = "iam-user-unused-credentials-check"
  maximum_execution_frequency = "TwentyFour_Hours"

  input_parameters = jsonencode({
    maxCredentialUsageAge : "30"
  })

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "mfa-enabled-for-iam-console-access" {
  name                        = "mfa-enabled-for-iam-console-access"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "multi-region-cloudtrail-enabled" {
  name                        = "multi-region-cloudtrail-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  input_parameters = jsonencode({
    cloudWatchLogsLogGroupArn : var.cloudtrail.cloudwatch_log_group_arn,
    includeManagementEvents : "true",
    readWriteType : "ALL",
    s3BucketName : var.cloudtrail.s3_bucket_id,
    snsTopicArn : var.cloudtrail.sns_topic_arn
  })

  source {
    owner             = "AWS"
    source_identifier = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

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

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "root-account-mfa-enabled" {
  name                        = "root-account-mfa-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "s3-account-level-public-access-blocks" {
  name = "s3-account-level-public-access-blocks"

  source {
    owner             = "AWS"
    source_identifier = "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "s3-bucket-public-read-prohibited" {
  name = "s3-bucket-public-read-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "s3-bucket-public-write-prohibited" {
  name = "s3-bucket-public-write-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "s3-bucket-server-side-encryption-enabled" {
  name = "s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "s3-bucket-ssl-requests-only" {
  name = "s3-bucket-ssl-requests-only"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SSL_REQUESTS_ONLY"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "securityhub-enabled" {
  name                        = "securityhub-enabled"
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "SECURITYHUB_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}

resource "aws_config_config_rule" "sns-encrypted-kms" {
  name = "sns-encrypted-kms"

  source {
    owner             = "AWS"
    source_identifier = "SNS_ENCRYPTED_KMS"
  }

  depends_on = [aws_config_configuration_recorder.aws-eu-west-2]

  tags = var.tags
}