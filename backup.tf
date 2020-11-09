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

module "backup-ap-northeast-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.ap-northeast-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-ap-northeast-2" {
  source = "./modules/backup"
  providers = {
    aws = aws.ap-northeast-2
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-ap-south-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.ap-south-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-ap-southeast-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.ap-southeast-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-ap-southeast-2" {
  source = "./modules/backup"
  providers = {
    aws = aws.ap-southeast-2
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-ca-central-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.ca-central-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-eu-central-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.eu-central-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-eu-north-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.eu-north-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-eu-west-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.eu-west-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-eu-west-2" {
  source = "./modules/backup"
  providers = {
    aws = aws.eu-west-2
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-eu-west-3" {
  source = "./modules/backup"
  providers = {
    aws = aws.eu-west-3
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-sa-east-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.sa-east-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-us-east-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.us-east-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-us-east-2" {
  source = "./modules/backup"
  providers = {
    aws = aws.us-east-2
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-us-west-1" {
  source = "./modules/backup"
  providers = {
    aws = aws.us-west-1
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}

module "backup-us-west-2" {
  source = "./modules/backup"
  providers = {
    aws = aws.us-west-2
  }
  iam_role_arn = aws_iam_role.backup.arn
  tags         = var.tags
}
