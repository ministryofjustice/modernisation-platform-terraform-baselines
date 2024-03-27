data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  iam_policy_logs_arn = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail.name}:log-stream:*"
}

# Enable CloudTrail
# As this is a multi-region trail, this resource doesn't set a provider,
# so it's configured in the region from the caller's identity.
resource "aws_cloudtrail" "cloudtrail" {
  name                          = "cloudtrail"
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  enable_log_file_validation    = true
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = true
  kms_key_id                    = var.cloudtrail_kms_key
  s3_bucket_name                = var.cloudtrail_bucket
  sns_topic_name                = aws_sns_topic.cloudtrail.arn

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
  name               = "cloudtrail"
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
  name   = "AWSCloudTrail"
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
  name              = "cloudtrail"
  kms_key_id        = var.cloudtrail_kms_key
  tags              = var.tags
  retention_in_days = var.retention_days
}

resource "aws_cloudwatch_log_stream" "cloudtrail-stream" {
  name           = data.aws_caller_identity.current.account_id
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
}

# # AWS CloudTrail: configure an S3 bucket
# module "cloudtrail-bucket" {
#   source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v6.0.4"
#   providers = {
#     aws.bucket-replication = aws.replication-region
#   }
#   acl                    = "log-delivery-write"
#   bucket_policy          = data.aws_iam_policy_document.cloudtrail.json
#   bucket_prefix          = "cloudtrail-"
#   custom_kms_key         = aws_kms_key.cloudtrail.arn
#   enable_lifecycle_rules = true
#   log_bucket             = var.main_logging_cloud
#   log_prefix             = "cloudtrail/log"
#   replication_role_arn   = var.replication_role_arn
#   tags                   = var.tags
# }

# module "cloudtrail-log-bucket" {
#   source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v6.0.4"
#   providers = {
#     aws.bucket-replication = aws.replication-region
#   }
#   acl                  = "log-delivery-write"
#   bucket_prefix        = "log-bucket"
#   replication_role_arn = var.replication_role_arn
#   tags                 = var.tags
# }

# Extrapolated from:
# https://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-s3-bucket-policy-for-cloudtrail.html
# data "aws_iam_policy_document" "cloudtrail" {
#   statement {
#     effect    = "Allow"
#     actions   = ["s3:GetBucketAcl"]
#     resources = [module.cloudtrail-bucket.bucket.arn]

#     principals {
#       type        = "Service"
#       identifiers = ["cloudtrail.amazonaws.com"]
#     }
#   }

#   statement {
#     effect    = "Allow"
#     actions   = ["s3:PutObject"]
#     resources = ["${module.cloudtrail-bucket.bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

#     principals {
#       type        = "Service"
#       identifiers = ["cloudtrail.amazonaws.com"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "s3:x-amz-acl"
#       values   = ["bucket-owner-full-control"]
#     }
#   }
# }

# SNS for CloudTrail
resource "aws_sns_topic" "cloudtrail" {
  name              = "cloudtrail"
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

# KMS for CloudTrail
# resource "aws_kms_key" "cloudtrail" {
#   deletion_window_in_days = 7
#   description             = "CloudTrail encryption key"
#   enable_key_rotation     = true
#   policy                  = data.aws_iam_policy_document.kms.json
#   tags                    = var.tags
# }

# resource "aws_kms_alias" "cloudtrail" {
#   name          = "alias/cloudtrail_key"
#   target_key_id = aws_kms_key.cloudtrail.id
# }

# IAM policy for KMS
# Extrapolated from AWS' default CMK policy, the SNS policy, and the CloudWatch logs policy:
# https://docs.aws.amazon.com/awscloudtrail/latest/userguide/default-cmk-policy.html
# https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-permissions-for-sns-notifications.html
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html
# data "aws_iam_policy_document" "kms" {
#   statement {
#     effect    = "Allow"
#     actions   = ["kms:*"]
#     resources = ["*"]

#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
#     }
#   }

#   statement {
#     effect    = "Allow"
#     actions   = ["kms:GenerateDataKey*"]
#     resources = ["*"]

#     condition {
#       test     = "StringLike"
#       variable = "kms:EncryptionContext:aws:cloudtrail:arn"
#       values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
#     }

#     principals {
#       type        = "Service"
#       identifiers = ["cloudtrail.amazonaws.com"]
#     }
#   }

#   statement {
#     effect    = "Allow"
#     actions   = ["kms:DescribeKey"]
#     resources = ["*"]

#     principals {
#       type        = "Service"
#       identifiers = ["cloudtrail.amazonaws.com"]
#     }
#   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "kms:Decrypt",
#       "kms:ReEncryptFrom"
#     ]
#     resources = ["*"]

#     condition {
#       test     = "StringEquals"
#       variable = "kms:CallerAccount"
#       values   = [data.aws_caller_identity.current.account_id]
#     }

#     condition {
#       test     = "StringLike"
#       variable = "kms:EncryptionContext:aws:cloudtrail:arn"
#       values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
#     }

#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
#   }

#   statement {
#     effect    = "Allow"
#     actions   = ["kms:CreateAlias"]
#     resources = ["*"]

#     condition {
#       test     = "StringEquals"
#       variable = "kms:ViaService"
#       values   = ["ec2.${data.aws_region.current.name}.amazonaws.com"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "kms:CallerAccount"
#       values   = [data.aws_caller_identity.current.account_id]
#     }

#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
#   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "kms:Decrypt",
#       "kms:ReEncryptFrom"
#     ]
#     resources = ["*"]

#     condition {
#       test     = "StringLike"
#       variable = "kms:EncryptionContext:aws:cloudtrail:arn"
#       values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "kms:CallerAccount"
#       values   = [data.aws_caller_identity.current.account_id]
#     }

#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
#   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "kms:GenerateDataKey*",
#       "kms:Decrypt"
#     ]
#     resources = ["*"]

#     principals {
#       type        = "Service"
#       identifiers = ["cloudtrail.amazonaws.com"]
#     }
#   }

#   # CloudWatch
#   statement {
#     effect = "Allow"
#     actions = [
#       "kms:Encrypt*",
#       "kms:Decrypt*",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:Describe*"
#     ]
#     resources = ["*"]

#     principals {
#       type        = "Service"
#       identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
#     }

#     condition {
#       test     = "ArnLike"
#       variable = "kms:EncryptionContext:aws:logs:arn"
#       values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
#     }
#   }
# }
