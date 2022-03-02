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
resource "aws_iam_policy" "config-publish-policy" {
  name   = "AWSConfigPublishPolicy"
  policy = data.aws_iam_policy_document.config-publish-policy.json
}

# Extrapolated from:
# https://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html and
# https://docs.aws.amazon.com/config/latest/developerguide/sns-topic-policy.html
data "aws_iam_policy_document" "config-publish-policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["${module.config-bucket.bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

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
    resources = [module.config-bucket.bucket.arn]
  }

  statement {
    effect  = "Allow"
    actions = ["sns:Publish"]
    resources = flatten([
      for enabled_region in [
        module.config-ap-northeast-1,
        module.config-ap-northeast-2,
        module.config-ap-south-1,
        module.config-ap-southeast-1,
        module.config-ap-southeast-2,
        module.config-ca-central-1,
        module.config-eu-central-1,
        module.config-eu-north-1,
        module.config-eu-west-1,
        module.config-eu-west-2,
        module.config-eu-west-3,
        module.config-sa-east-1,
        module.config-us-east-1,
        module.config-us-east-2,
        module.config-us-west-1,
        module.config-us-west-2
        ] : [
        for enabled_module in enabled_region : [
          enabled_module.sns_topic_arn
        ]
      ]
    ])
  }
}

resource "aws_iam_role_policy_attachment" "config-publish-policy" {
  role       = aws_iam_role.config.id
  policy_arn = aws_iam_policy.config-publish-policy.arn
}

# AWS Config: configure an S3 bucket
module "config-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v6.0.2"
  providers = {
    aws.bucket-replication = aws.replication-region
  }
  replication_enabled = false
  bucket_policy       = [data.aws_iam_policy_document.config-s3-policy.json]
  bucket_prefix       = "config-"

  lifecycle_rule = [
    {
      id      = "main"
      enabled = "Enabled"

      tags = {
        rule      = "log"
        autoclean = "true"
      }

      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
          }, {
          days          = 365
          storage_class = "GLACIER"
        }
      ]

      expiration = {
        days = 730
      }

      noncurrent_version_transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
          }, {
          days          = 365
          storage_class = "GLACIER"
        }
      ]

      noncurrent_version_expiration = {
        days = 730
      }
    }
  ]

  tags = var.tags
}

# AWS Config: bucket policy, and require secure transport
# Extrapolated from:
# https://docs.aws.amazon.com/config/latest/developerguide/s3-bucket-policy.html
# https://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html
data "aws_iam_policy_document" "config-s3-policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]
    resources = [module.config-bucket.bucket.arn]

    principals {
      identifiers = ["config.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${module.config-bucket.bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    principals {
      identifiers = ["config.amazonaws.com"]
      type        = "Service"
    }
  }

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
    resources = [module.config-bucket.bucket.arn]

    principals {
      identifiers = [aws_iam_role.config.arn]
      type        = "AWS"
    }
  }
}

# Enable Config in each region
module "config-ap-northeast-1" {
  for_each = contains(var.enabled_config_regions, "ap-northeast-1") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.ap-northeast-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

module "config-ap-northeast-2" {
  for_each = contains(var.enabled_config_regions, "ap-northeast-2") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.ap-northeast-2
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

module "config-ap-south-1" {
  for_each = contains(var.enabled_config_regions, "ap-south-1") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.ap-south-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

module "config-ap-southeast-1" {
  for_each = contains(var.enabled_config_regions, "ap-southeast-1") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.ap-southeast-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

module "config-ap-southeast-2" {
  for_each = contains(var.enabled_config_regions, "ap-southeast-2") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.ap-southeast-2
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

module "config-ca-central-1" {
  for_each = contains(var.enabled_config_regions, "ca-central-1") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.ca-central-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

module "config-eu-central-1" {
  for_each = contains(var.enabled_config_regions, "eu-central-1") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.eu-central-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

module "config-eu-north-1" {
  for_each = contains(var.enabled_config_regions, "eu-north-1") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.eu-north-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

module "config-eu-west-1" {
  for_each = contains(var.enabled_config_regions, "eu-west-1") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.eu-west-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

module "config-eu-west-2" {
  for_each = contains(var.enabled_config_regions, "eu-west-2") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.eu-west-2
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

module "config-eu-west-3" {
  for_each = contains(var.enabled_config_regions, "eu-west-3") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.eu-west-3
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

module "config-sa-east-1" {
  for_each = contains(var.enabled_config_regions, "sa-east-1") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.sa-east-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

module "config-us-east-1" {
  for_each = contains(var.enabled_config_regions, "us-east-1") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.us-east-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

module "config-us-east-2" {
  for_each = contains(var.enabled_config_regions, "us-east-2") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.us-east-2
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

module "config-us-west-1" {
  for_each = contains(var.enabled_config_regions, "us-west-1") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.us-west-1
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

module "config-us-west-2" {
  for_each = contains(var.enabled_config_regions, "us-west-2") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.us-west-2
  }
  iam_role_arn    = aws_iam_role.config.arn
  s3_bucket_id    = module.config-bucket.bucket.id
  root_account_id = var.root_account_id
  home_region     = data.aws_region.current.name
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}

