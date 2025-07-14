
resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}

# AWS Config: configure an S3 bucket
module "config-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=9facf9fc8f8b8e3f93ffbda822028534b9a75399" # v9.0.0
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
      prefix  = ""
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
# Source:
# https://docs.aws.amazon.com/config/latest/developerguide/s3-bucket-policy.html
data "aws_iam_policy_document" "config-s3-policy" {
  version = "2012-10-17"

  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [module.config-bucket.bucket.arn]

    principals {
      identifiers = ["config.amazonaws.com"]
      type        = "Service"
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.current_account_id]
    }

  }

  statement {
    sid    = "AWSConfigBucketExistenceCheck"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [module.config-bucket.bucket.arn]

    principals {
      identifiers = ["config.amazonaws.com"]
      type        = "Service"
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.current_account_id]
    }

  }

  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["${module.config-bucket.bucket.arn}/*"]

    principals {
      identifiers = ["config.amazonaws.com"]
      type        = "Service"
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.current_account_id]
    }

  }

}

# Add Multi-Region KMS and Policy for use by SNS
# KMS Key & Policy for the SNS Topic. This is required for the user of a service-linked role.

resource "aws_kms_key" "config-sns-key" {
  bypass_policy_lockout_safety_check = false
  description                        = "KMS key for AWS Config SNS topic"
  multi_region                       = true
  policy                             = data.aws_iam_policy_document.config-sns-key-policy.json
  tags                               = var.tags
}

resource "aws_kms_alias" "config-sns-key-alias" {
  name          = "alias/config-sns-key"
  target_key_id = aws_kms_key.config-sns-key.key_id
}

data "aws_iam_policy_document" "config-sns-key-policy" {
  #checkov:skip=CKV_AWS_109:"Policy is directly related to the resource"
  #checkov:skip=CKV_AWS_111:"Policy is directly related to the resource"
  #checkov:skip=CKV_AWS_356:"Policy is directly related to the resource"

  statement {
    sid    = "Allow management access of the key"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*",
    ]
    principals {
      type = "AWS"
      identifiers = [
        var.current_account_id
      ]
    }
  }

  statement {
    sid       = "AWSConfigSNSPolicy"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
    resources = ["*"]
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

}



# Enable Config in each region
module "config-ap-northeast-1" {
  for_each = contains(var.enabled_config_regions, "ap-northeast-1") ? local.enabled : local.not_enabled

  source = "./modules/config"
  providers = {
    aws = aws.ap-northeast-1
  }
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
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
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
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
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
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
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
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
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
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
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
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
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
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
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
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
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
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
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
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
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
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
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
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
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
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
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
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
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
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
  iam_role_arn       = aws_iam_service_linked_role.config.arn
  s3_bucket_id       = local.config_bucket
  root_account_id    = var.root_account_id
  home_region        = data.aws_region.current.name
  current_account_id = var.current_account_id
  sns_topic_key      = aws_kms_key.config-sns-key.key_id
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = local.cloudtrail_bucket
    sns_topic_arn            = module.cloudtrail.sns_topic_arn,
  }
  tags = var.tags
}
