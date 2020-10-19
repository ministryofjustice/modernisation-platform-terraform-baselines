data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# AWS Config: configure an IAM role
resource "aws_iam_role" "config" {
  name               = "AWSConfig"
  assume_role_policy = data.aws_iam_policy_document.config-assume-role-policy.json
  tags               = var.tags
}

# AWS Config: assume role policy
data "aws_iam_policy_document" "config-assume-role-policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

# AWS Config: service role policy
# See: https://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html
resource "aws_iam_role_policy_attachment" "config-service-role-policy" {
  role       = aws_iam_role.config.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# AWS Config: publish to S3 and SNS policy
resource "aws_iam_role_policy" "config-publish-policy" {
  role   = aws_iam_role.config.id
  policy = data.aws_iam_policy_document.config-publish-policy.json
}

# Extrapolated from:
# https://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html and
# https://docs.aws.amazon.com/config/latest/developerguide/sns-topic-policy.html
data "aws_iam_policy_document" "config-publish-policy" {
  version = "2012-10-17"
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.config.id}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringLike"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]
    resources = ["arn:aws:s3:::${aws_s3_bucket.config.arn}"]
  }

  statement {
    effect  = "Allow"
    actions = ["sns:Publish"]
    resources = [
      module.config-eu-west-2.sns_topic_arn
    ]
  }
}

# AWS Config: configure an S3 bucket
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

resource "aws_s3_bucket_policy" "config" {
  bucket = aws_s3_bucket.config.bucket
  policy = data.aws_iam_policy_document.config.json
}

# AWS Config: bucket policy, and require secure transport
# Extrapolated from:
# https://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html
data "aws_iam_policy_document" "config" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketNotification",
      "s3:GetBucketPolicy",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration"
    ]
    resources = [aws_s3_bucket.config.arn]

    principals {
      identifiers = [aws_iam_role.config.arn]
      type        = "AWS"
    }
  }

  statement {
    sid     = "Require SSL"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.config.arn,
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

# Enable Config in each region
module "config-ap-northeast-1" {
  source = "./modules/config"
  providers = {
    aws = aws.ap-northeast-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

module "config-ap-northeast-2" {
  source = "./modules/config"
  providers = {
    aws = aws.ap-northeast-2
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

module "config-ap-south-1" {
  source = "./modules/config"
  providers = {
    aws = aws.ap-south-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

module "config-ap-southeast-1" {
  source = "./modules/config"
  providers = {
    aws = aws.ap-southeast-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

module "config-ap-southeast-2" {
  source = "./modules/config"
  providers = {
    aws = aws.ap-southeast-2
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

module "config-ca-central-1" {
  source = "./modules/config"
  providers = {
    aws = aws.ca-central-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

module "config-eu-central-1" {
  source = "./modules/config"
  providers = {
    aws = aws.eu-central-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

module "config-eu-north-1" {
  source = "./modules/config"
  providers = {
    aws = aws.eu-north-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

module "config-eu-west-1" {
  source = "./modules/config"
  providers = {
    aws = aws.eu-west-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

module "config-eu-west-2" {
  source = "./modules/config"
  providers = {
    aws = aws.eu-west-2
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

module "config-eu-west-3" {
  source = "./modules/config"
  providers = {
    aws = aws.eu-west-3
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

module "config-sa-east-1" {
  source = "./modules/config"
  providers = {
    aws = aws.sa-east-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

module "config-us-east-1" {
  source = "./modules/config"
  providers = {
    aws = aws.us-east-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

module "config-us-east-2" {
  source = "./modules/config"
  providers = {
    aws = aws.us-east-2
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

module "config-us-west-1" {
  source = "./modules/config"
  providers = {
    aws = aws.us-west-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

module "config-us-west-2" {
  source = "./modules/config"
  providers = {
    aws = aws.us-west-2
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = aws_s3_bucket.config.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  tags = var.tags
}

