/*
  IAM role for AWS Backup
*/
resource "aws_iam_role" "backup" {
  name               = "AWSBackup"
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

module "backup-ap-northeast-1" {
  for_each = contains(var.enabled_backup_regions, "ap-northeast-1") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.ap-northeast-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-ap-northeast-2" {
  for_each = contains(var.enabled_backup_regions, "ap-northeast-2") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.ap-northeast-2
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-ap-south-1" {
  for_each = contains(var.enabled_backup_regions, "ap-south-1") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.ap-south-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-ap-southeast-1" {
  for_each = contains(var.enabled_backup_regions, "ap-southeast-1") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.ap-southeast-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-ap-southeast-2" {
  for_each = contains(var.enabled_backup_regions, "ap-southeast-2") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.ap-southeast-2
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-ca-central-1" {
  for_each = contains(var.enabled_backup_regions, "ca-central-1") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.ca-central-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-eu-central-1" {
  for_each = contains(var.enabled_backup_regions, "eu-central-1") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.eu-central-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-eu-north-1" {
  for_each = contains(var.enabled_backup_regions, "eu-north-1") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.eu-north-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-eu-west-1" {
  for_each = contains(var.enabled_backup_regions, "eu-west-1") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.eu-west-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-eu-west-2" {
  for_each = contains(var.enabled_backup_regions, "eu-west-2") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.eu-west-2
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-eu-west-3" {
  for_each = contains(var.enabled_backup_regions, "eu-west-3") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.eu-west-3
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-sa-east-1" {
  for_each = contains(var.enabled_backup_regions, "sa-east-1") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.sa-east-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-us-east-1" {
  for_each = contains(var.enabled_backup_regions, "us-east-1") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.us-east-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-us-east-2" {
  for_each = contains(var.enabled_backup_regions, "us-east-2") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.us-east-2
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-us-west-1" {
  for_each = contains(var.enabled_backup_regions, "us-west-1") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.us-west-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-us-west-2" {
  for_each = contains(var.enabled_backup_regions, "us-west-2") ? local.enabled : local.not_enabled
  depends_on = [module.securityhub-alarms]
  source = "./modules/backup"
  providers = {
    aws = aws.us-west-2
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}
