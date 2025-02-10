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
resource "aws_sns_topic" "default" {
  name              = "config"
  kms_master_key_id = var.sns_topic_key
  tags              = var.tags
}

## Add Policy for the SNS Topic.

resource "aws_sns_topic_policy" "config-sns-policy" {
  arn    = aws_sns_topic.default.arn
  policy = data.aws_iam_policy_document.config-sns-policy.json
}

data "aws_iam_policy_document" "config-sns-policy" {
  version = "2012-10-17"

  statement {
    sid       = "AllowConfigPublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.default.arn]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.current_account_id]
    }
  }

  statement {
    sid       = "AllowEventsPublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.default.arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.current_account_id]
    }
  }

}

# Configure AWS Config rules

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

resource "aws_config_config_rule" "s3-bucket-server-side-encryption-enabled" {
  name = "s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
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
