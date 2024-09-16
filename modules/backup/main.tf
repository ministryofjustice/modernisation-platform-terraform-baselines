locals {
  cold_storage_after = 30
  is_production      = can(regex("production|default", terraform.workspace))
}

data "aws_caller_identity" "current" {}

# Fetch the current AWS region
data "aws_region" "current" {}

# Backup alarms KMS multi-Region
resource "aws_kms_key" "backup_alarms_multi_region" {
  deletion_window_in_days = 7
  description             = "Backup alarms encryption key"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.backup-alarms-kms.json
  tags                    = var.tags
  multi_region            = true
}

resource "aws_kms_alias" "backup_alarms_multi_region" {
  name          = var.aws_kms_alias_name
  target_key_id = aws_kms_key.backup_alarms_multi_region.id
}

resource "aws_kms_replica_key" "backup_alarms_multi_region_replica" {
  description             = "AWS Secretsmanager CMK replica key"
  deletion_window_in_days = 30
  primary_key_arn         = aws_kms_key.backup_alarms_multi_region.arn
  provider                = aws.modernisation-platform-eu-west-1
}

resource "aws_kms_alias" "backup_alarms_multi_region_replica" {
  name          = "alias/backup_alarms-multi-region-replica"
  target_key_id = aws_kms_replica_key.backup_alarms_multi_region_replica.id
}

data "aws_iam_policy_document" "backup-alarms-kms" {

  #checkov:skip=CKV_AWS_356: ""
  #checkov:skip=CKV_AWS_111: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_109: "Ensure IAM policies does not allow permissions management / resource exposure without constraints - This is applied to a specific SNS topic"

  # Statement allowing root account full KMS access
  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # Statement allowing CloudWatch specific actions
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

  # Statement allowing specific IAM user to replicate the KMS key dynamically
  statement {
    effect    = "Allow"
    actions   = ["kms:ReplicateKey"]
    resources = ["*"]

    principals {
      type = "AWS"
      # Dynamically referencing the IAM user for replication permission
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/testing-ci"]
    }
  }
}



# Define the SNS topic, conditionally created if the region is eu-west-2 and is production
resource "aws_sns_topic" "backup_vault_topic" {
  #checkov:skip=CKV_AWS_26:"topic is encrypted, but doesn't like the local reference"  
  count             = (local.is_production && data.aws_region.current.name == "eu-west-2") ? 1 : 0
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
  count = (local.is_production && data.aws_region.current.name == "eu-west-2") ? 1 : 0
  #checkov:skip=CKV_AWS_26:"topic is encrypted, but doesn't like the local reference"
  kms_master_key_id = aws_kms_key.backup_alarms_multi_region.id
  name              = var.backup_aws_sns_topic_name
  tags = merge(var.tags, {
    Description = "This backup topic is so the MP team can subscribe to backup notifications from selected accounts and teams using member-unrestricted accounts can create their own subscriptions"
  })
}

# Attaches the SNS topic to the backup vault to subscribe for notifications
resource "aws_backup_vault_notifications" "aws_backup_vault_notifications" {
  count               = (local.is_production && data.aws_region.current.name == "eu-west-2") ? 1 : 0
  backup_vault_events = ["BACKUP_JOB_FAILED"]
  backup_vault_name   = aws_backup_vault.default.name
  sns_topic_arn       = aws_sns_topic.backup_failure_topic[0].arn
}

