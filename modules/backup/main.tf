locals {
  cold_storage_after = 30
}

resource "aws_backup_vault" "default" {
  name = "everything"
  tags = var.tags
}

resource "aws_backup_plan" "default" {
  name = "backup-daily-cold-storage-monthly-retain-120-days"

  rule {
    rule_name         = "backup-daily-cold-storage-monthly-retain-120-days"
    target_vault_name = aws_backup_vault.default.name
    # Backup every day at 00:30am
    schedule = "cron(30 0 * * ? *)"

    # The lifecycle only supports EFS file system backups at present.
    # There is a minimum amount of days a backup must be in cold storage (90 days)
    # before being deleted.
    # See: https://docs.aws.amazon.com/aws-backup/latest/devguide/API_Lifecycle.html
    lifecycle {
      cold_storage_after = local.cold_storage_after
      delete_after       = (local.cold_storage_after + 90)
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
