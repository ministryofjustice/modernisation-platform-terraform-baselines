data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  iam_policy_logs_arn = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail.name}:log-stream:*"
}

# Enable CloudTrail
# As this is a multi-region trail, this resource doesn't set a provider,
# so it's configured in the region from the caller's identity.
resource "aws_cloudtrail" "cloudtrail" {
  name                          = var.cloudtrail_name
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  enable_log_file_validation    = true
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = true
  kms_key_id                    = var.cloudtrail_kms_key
  s3_bucket_name                = var.cloudtrail_bucket
  sns_topic_name                = aws_sns_topic.cloudtrail.name

  dynamic "event_selector" {
    for_each = var.enable_cloudtrail_s3_mgmt_events ? [1] : []
    # If enable_cloudtrail_s3_mgmt_events is enabled, the below block is created
    content {
      include_management_events = true
      read_write_type           = "All"

      data_resource {
        type   = "AWS::S3::Object"
        values = ["arn:aws:s3"]
      }
    }
  }

  # wait for sns topic policy to be attached 
  depends_on = [aws_sns_topic_policy.cloudtrail]

  tags = var.tags
}

# IAM role for CloudTrail
resource "aws_iam_role" "cloudtrail" {
  name               = var.cloudtrail_name
  assume_role_policy = data.aws_iam_policy_document.cloudtrail-assume-role-policy.json
  tags               = var.tags
}

# IAM role: assume role policy
data "aws_iam_policy_document" "cloudtrail-assume-role-policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

# IAM role: role log policy
resource "aws_iam_policy" "cloudtrail" {
  name   = var.cloudtrail_policy_name
  policy = data.aws_iam_policy_document.cloudtrail-role-policy.json
}

resource "aws_iam_role_policy_attachment" "cloudtrail" {
  role       = aws_iam_role.cloudtrail.id
  policy_arn = aws_iam_policy.cloudtrail.arn
}

# Extrapolated from:
# https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-required-policy-for-cloudwatch-logs.html
data "aws_iam_policy_document" "cloudtrail-role-policy" {
  statement {
    effect  = "Allow"
    actions = ["logs:CreateLogStream"]

    resources = [local.iam_policy_logs_arn]
  }

  statement {
    effect  = "Allow"
    actions = ["logs:PutLogEvents"]

    resources = [local.iam_policy_logs_arn]
  }
}

# CloudWatch log groups & log streams for CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = var.cloudtrail_name
  kms_key_id        = var.cloudtrail_kms_key
  tags              = var.tags
  retention_in_days = var.retention_days
}

resource "aws_cloudwatch_log_stream" "cloudtrail-stream" {
  name           = data.aws_caller_identity.current.account_id
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
}

# SNS for CloudTrail
resource "aws_sns_topic" "cloudtrail" {
  name              = var.cloudtrail_name
  kms_master_key_id = var.cloudtrail_kms_key
  tags              = var.tags
}

resource "aws_sns_topic_policy" "cloudtrail" {
  arn    = aws_sns_topic.cloudtrail.arn
  policy = data.aws_iam_policy_document.cloudtrail-sns.json
}

data "aws_iam_policy_document" "cloudtrail-sns" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.cloudtrail.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}
