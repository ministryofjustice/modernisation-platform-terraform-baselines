locals {
  cold_storage_after = 30
  is_production      = can(regex("production|default", terraform.workspace))
}

data "aws_caller_identity" "current" {}

# Fetch the current AWS region
data "aws_region" "current" {}

# Backup alarms KMS multi-Region
resource "aws_kms_key" "backup_alarms_multi_region" {
  bypass_policy_lockout_safety_check = false
  deletion_window_in_days            = 7
  description                        = "Backup alarms encryption key"
  enable_key_rotation                = true
  policy                             = data.aws_iam_policy_document.backup-alarms-kms.json
  tags                               = var.tags
  multi_region                       = true
}

resource "aws_kms_alias" "backup_alarms_multi_region" {
  name          = var.aws_kms_alias_name
  target_key_id = aws_kms_key.backup_alarms_multi_region.id
}

data "aws_iam_policy_document" "backup-alarms-kms" {

  #checkov:skip=CKV_AWS_356: ""
  #checkov:skip=CKV_AWS_111: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_109: "Ensure IAM policies does not allow permissions management / resource exposure without constraints - This is applied to a specific SNS topic"

  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
  }
}

resource "aws_sns_topic" "backup_vault_topic" {
  kms_master_key_id = aws_kms_key.backup_alarms_multi_region.id
  name              = var.backup_vault_lock_sns_topic_name
  tags = merge(var.tags, {
    Description = "This backup topic is so the MP team can subscribe to backup vault lock being turned off and member accounts can create their own subscriptions"
  })
}

resource "aws_backup_vault" "default" {
  #checkov:skip=CKV_AWS_166: "Ensure Backup Vault is encrypted at rest using KMS CMK - Tricky to implement, hence using AWS managed KMS key"
  name = var.aws_backup_vault_name
  tags = var.tags
}

# Backup vault lock
resource "aws_backup_vault_lock_configuration" "default" {
  count              = local.is_production ? 1 : 0
  backup_vault_name  = aws_backup_vault.default.name
  min_retention_days = var.min_vault_retention_days
  max_retention_days = var.max_vault_retention_days

  changeable_for_days = 3 # Required for compliance mode
}


# Production backups
resource "aws_backup_plan" "default" {
  #checkov:skip=CKV_AWS_166: "Ensure Backup Vault is encrypted at rest using KMS CMK - Tricky to implement, hence using AWS managed KMS key"

  name = var.production_backup_plan_name
  rule {
    rule_name         = "backup-daily-retain-30-days"
    target_vault_name = aws_backup_vault.default.name

    # Backup every day at 00:30am
    schedule = "cron(30 0 * * ? *)"

    # The amount of time in minutes to start and finish a backup
    ## Start the backup within 1 hour of the schedule
    start_window = (1 * 60)
    ## Complete the backup within 6 hours of starting
    completion_window = (6 * 60)
    # The lifecycle only supports EFS file system backups at present.
    # There is a minimum amount of days a backup must be in cold storage (90 days)
    # before being deleted.
    # See: https://docs.aws.amazon.com/aws-backup/latest/devguide/API_Lifecycle.html
    lifecycle {
      delete_after = local.cold_storage_after
    }
  }

  advanced_backup_setting {
    backup_options = {
      WindowsVSS = "enabled"
    }
    resource_type = "EC2"
  }

  tags = var.tags
}

resource "aws_backup_selection" "production" {
  name         = var.production_backup_selection_name
  iam_role_arn = var.iam_role_arn
  plan_id      = aws_backup_plan.default.id
  resources    = ["*"]

  condition {
    string_equals {
      key   = "aws:ResourceTag/is-production"
      value = "true"
    }
    string_not_equals {
      key   = "aws:ResourceTag/backup"
      value = "false"
    }
  }
}

# Non production backups
resource "aws_backup_plan" "non_production" {
  name = var.non_production_backup_plan_name

  rule {
    rule_name         = "backup-daily-cold-storage-monthly-retain-30-days"
    target_vault_name = aws_backup_vault.default.name

    # Backup every day at 00:30am
    schedule = "cron(30 0 * * ? *)"

    # The amount of time in minutes to start and finish a backup
    ## Start the backup within 1 hour of the schedule
    start_window = (1 * 60)
    ## Complete the backup within 6 hours of starting
    completion_window = (6 * 60)

    lifecycle {
      delete_after = var.reduced_preprod_backup_retention ? 7 : var.non_prod_backup_retention_days
    }
  }

  advanced_backup_setting {
    backup_options = {
      WindowsVSS = "enabled"
    }
    resource_type = "EC2"
  }

  tags = var.tags
}

resource "aws_backup_selection" "non_production" {
  name         = var.non_production_backup_selection_name
  iam_role_arn = var.iam_role_arn
  plan_id      = aws_backup_plan.non_production.id
  resources    = ["*"]

  condition {
    string_not_equals {
      key   = "aws:ResourceTag/is-production"
      value = "true"
    }
    string_equals {
      key   = "aws:ResourceTag/backup"
      value = "true"
    }
  }
}

# SNS topic
# trivy:ignore:avd-aws-0136
resource "aws_sns_topic" "backup_failure_topic" {
  kms_master_key_id = aws_kms_key.backup_alarms_multi_region.id
  name              = var.backup_aws_sns_topic_name
  tags = merge(var.tags, {
    Description = "Allows customers to subscribe to backup notifications for notification on failed jobs"
  })
}

# Attaches the SNS topic to the backup vault to subscribe for notifications
resource "aws_backup_vault_notifications" "aws_backup_vault_notifications" {
  backup_vault_events = ["BACKUP_JOB_FAILED"]
  backup_vault_name   = aws_backup_vault.default.name
  sns_topic_arn       = aws_sns_topic.backup_failure_topic.arn
}

###############################################################################
# AWS Backup Regional Service Opt-In 
###############################################################################

locals {

  backup_enabled_regions = [
    "eu-central-1",
    "eu-west-1",
    "eu-west-2",
    "eu-west-3",
    "us-east-1"
  ]

  backup_resource_types_by_region = {

    # Full-feature regions 
    "eu-west-1" = {
      Aurora                     = true
      CloudFormation             = true
      DSQL                       = true
      DocumentDB                 = true
      DynamoDB                   = true
      EBS                        = true
      EC2                        = true
      EFS                        = true
      EKS                        = true
      FSx                        = true
      Neptune                    = true
      RDS                        = true
      Redshift                   = true
      "Redshift Serverless"      = true
      S3                         = true
      "SAP HANA on Amazon EC2"   = true
      "Storage Gateway"          = true
      Timestream                 = true
      VirtualMachine             = true
    }

    "eu-west-2" = {
      Aurora                     = true
      CloudFormation             = true
      DSQL                       = true
      DocumentDB                 = true
      DynamoDB                   = true
      EBS                        = true
      EC2                        = true
      EFS                        = true
      EKS                        = true
      FSx                        = true
      Neptune                    = true
      RDS                        = true
      Redshift                   = true
      "Redshift Serverless"      = true
      S3                         = true
      "SAP HANA on Amazon EC2"   = true
      "Storage Gateway"          = true
      VirtualMachine             = true
    }

    # Limited-feature regions
    "us-east-1" = {
      Aurora           = true
      DynamoDB         = true
      EBS              = true
      EC2              = true
      EFS              = true
      RDS              = true
      "Storage Gateway" = true
    }

    "eu-west-3" = {
      Aurora           = true
      DynamoDB         = true
      EBS              = true
      EC2              = true
      EFS              = true
      RDS              = true
      "Storage Gateway" = true
    }

    "eu-central-1" = {
      Aurora           = true
      DynamoDB         = true
      EBS              = true
      EC2              = true
      EFS              = true
      RDS              = true
      "Storage Gateway" = true
    }
  }

  enable_backup_region_settings = contains(
    local.backup_enabled_regions,
    data.aws_region.current.region
  )

  backup_resource_types = lookup(
    local.backup_resource_types_by_region,
    data.aws_region.current.region,
    {}
  )
}

resource "aws_backup_region_settings" "this" {
  count = local.enable_backup_region_settings ? 1 : 0

  resource_type_opt_in_preference = local.backup_resource_types
}
