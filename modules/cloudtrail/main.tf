data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

resource "aws_cloudtrail" "cloudtrail" {
  name                          = "cloudtrail"
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  enable_log_file_validation    = true
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = true
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  sns_topic_name                = "cloudtrail"

  event_selector {
    include_management_events = true
    read_write_type           = "All"

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3"]
    }
  }

  tags = var.tags
}

# IAM role for CloudTrail
resource "aws_iam_role" "cloudtrail" {
  name               = "cloudtrail"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_role_assume_role_policy.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "cloudtrail" {
  name   = "cloudtrail"
  role   = aws_iam_role.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_role_policy.json
}

data "aws_iam_policy_document" "cloudtrail_role_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["logs:CreateLogStream"]

    resources = [
      "arn:${data.aws_partition.current.partition}:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail.name}:log-stream:*",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["logs:PutLogEvents"]

    resources = [
      "arn:${data.aws_partition.current.partition}:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail.name}:log-stream:*",
    ]
  }
}

# CloudWatch log groups & log streams for CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name       = "cloudtrail"
  kms_key_id = aws_kms_key.cloudtrail.arn
  tags       = var.tags
}

resource "aws_cloudwatch_log_stream" "cloudtrail_stream" {
  name           = data.aws_caller_identity.current.account_id
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
}

# S3 bucket for CloudTrail
resource "aws_s3_bucket" "cloudtrail" {
  bucket_prefix = "cloudtrail-"
  acl           = "log-delivery-write"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.cloudtrail.arn
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_transition {
      days          = 30
      storage_class = "GLACIER"
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }

  versioning {
    enabled = true
  }

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket_policy.cloudtrail.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "cloudtrail" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }

  statement {
    sid       = "Require SSL"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.cloudtrail.arn}/*"]

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

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail.json
}

# SNS for CloudTrail
resource "aws_sns_topic" "cloudtrail" {
  name = "cloudtrail"
  tags = var.tags
}

resource "aws_sns_topic_policy" "cloudtrail" {
  arn    = aws_sns_topic.cloudtrail.arn
  policy = data.aws_iam_policy_document.cloudtrail-sns.json
}

data "aws_iam_policy_document" "cloudtrail-sns" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.cloudtrail.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "kms" {
  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["logs.eu-west-2.amazonaws.com"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Describe*"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "kms_roles" {
  statement {
    actions   = ["kms:Decrypt"]
    effect    = "Allow"
    resources = ["*"]
    sid       = "AllowRolesToAccess"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "kms_merged" {
  source_json   = data.aws_iam_policy_document.kms.json
  override_json = data.aws_iam_policy_document.kms_roles.json
}

resource "aws_kms_key" "cloudtrail" {
  deletion_window_in_days = 7
  description             = "CloudTrail encryption key"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_merged.json
  tags                    = var.tags
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/cloudtrail_key"
  target_key_id = aws_kms_key.cloudtrail.id
}
