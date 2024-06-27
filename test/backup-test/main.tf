module "backup-test" {
  source                               = "../../modules/backup"
  iam_role_arn                         = aws_iam_role.backup.arn
  aws_backup_vault_name                = var.aws_backup_vault_name
  production_backup_plan_name          = var.production_backup_plan_name
  production_backup_selection_name     = var.production_backup_selection_name
  non_production_backup_plan_name      = var.non_production_backup_plan_name
  non_production_backup_selection_name = var.non_production_backup_selection_name
  backup_aws_sns_topic_name            = var.backup_aws_sns_topic_name
  max_vault_retention_days            = var.max_vault_retention_days
  min_vault_retention_days            = var.min_vault_retention_days
  backup_vault_lock_sns_topic_name    = var.backup_vault_lock_sns_topic_name
}

/*
  IAM role for AWS Backup
*/
resource "aws_iam_role" "backup" {
  name               = var.aws_iam_role_backup_name
  assume_role_policy = data.aws_iam_policy_document.backup-assume-role-policy.json
}

data "aws_iam_policy_document" "backup-assume-role-policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backupS3" {
  role       = aws_iam_role.backup.id
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
}