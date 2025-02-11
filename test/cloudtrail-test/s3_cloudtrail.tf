# trivy:ignore:AVD-AWS-0088
# trivy:ignore:AVD-AWS-0132
resource "aws_s3_bucket" "cloudtrail_s3_bucket" {
  # checkov:skip=CKV_AWS_18: Ephemeral bucket used for tests
  # checkov:skip=CKV_AWS_21
  # checkov:skip=CKV_AWS_144
  # checkov:skip=CKV_AWS_145
  # checkov:skip=CKV2_AWS_61
  # checkov:skip=CKV2_AWS_62
  bucket_prefix = var.cloudtrail_bucket
  force_destroy = true
  tags          = local.tags
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_s3_bucket" {
  bucket = aws_s3_bucket.cloudtrail_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
