resource "aws_s3_bucket" "cloudtrail_s3_bucket" {
  bucket        = var.cloudtrail_bucket
  force_destroy = true
  tags          = local.tags
}

resource "aws_s3_bucket_policy" "s3_cloudtrail_policy" {
  depends_on = [aws_s3_bucket.cloudtrail_s3_bucket]
  bucket     = aws_s3_bucket.cloudtrail_s3_bucket.id
  policy     = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
}

data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    sid       = "AllowListBucketACL"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail_s3_bucket.arn]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowOnlyEncryptedObjects"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail_s3_bucket.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }

  statement {
    sid       = "DenyUnencryptedData"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail_s3_bucket.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "allowReadListToLoggingAccount_1"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetBucketTagging",
      "s3:GetBucketLogging",
      "s3:ListBucketVersions",
      "s3:ListBucket",
      "s3:GetBucketPolicy",
      "s3:GetEncryptionConfiguration",
      "s3:GetObjectTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:GetObjectVersion"
    ]
    resources = [
      aws_s3_bucket.cloudtrail_s3_bucket.arn,
      format("%s/*", aws_s3_bucket.cloudtrail_s3_bucket.arn)
    ]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}