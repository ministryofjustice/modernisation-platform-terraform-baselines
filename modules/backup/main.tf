locals {
  cold_storage_after = 30
}

resource "aws_backup_vault" "default" {
  #checkov:skip=CKV_AWS_166: "Ensure Backup Vault is encrypted at rest using KMS CMK - Tricky to implement, hence using AWS managed KMS key"

  name = var.aws_backup_vault_name
  tags = var.tags
}

# Backup vault lock
resource "aws_backup_vault_lock_configuration" "default" {
  backup_vault_name = aws_backup_vault.default.name
  changeable_for_days = 3
  min_retention_days = 30
  max_retention_days = 60
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
      delete_after = 30
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
  kms_master_key_id = var.sns_backup_topic_key
  name              = var.backup_aws_sns_topic_name
  tags = merge(var.tags, {
    Description = "This backup topic is so the MP team can subscribe to backup notifications from selected accounts and teams using member-unrestricted accounts can create their own subscriptions"
  })
}

# Attaches the SNS topic to the backup vault to subscribe for notifications
resource "aws_backup_vault_notifications" "aws_backup_vault_notifications" {
  backup_vault_events = ["BACKUP_JOB_FAILED"]
  backup_vault_name   = aws_backup_vault.default.name
  sns_topic_arn       = aws_sns_topic.backup_failure_topic.arn
}