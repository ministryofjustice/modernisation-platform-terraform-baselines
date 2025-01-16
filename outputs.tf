locals {
  backup_modules = {
    "ap-northeast-1" = module.backup-ap-northeast-1
    "ap-northeast-2" = module.backup-ap-northeast-2
    "ap-south-1"     = module.backup-ap-south-1
    "ap-southeast-1" = module.backup-ap-southeast-1
    "ap-southeast-2" = module.backup-ap-southeast-2
    "ca-central-1"   = module.backup-ca-central-1
    "eu-central-1"   = module.backup-eu-central-1
    "eu-north-1"     = module.backup-eu-north-1
    "eu-west-1"      = module.backup-eu-west-1
    "eu-west-2"      = module.backup-eu-west-2
    "eu-west-3"      = module.backup-eu-west-3
    "sa-east-1"      = module.backup-sa-east-1
    "us-east-1"      = module.backup-us-east-1
    "us-east-2"      = module.backup-us-east-2
    "us-west-1"      = module.backup-us-west-1
    "us-west-2"      = module.backup-us-west-2
  }
}

output "backup_failure_topics" {
  value = { for key, value in local.backup_modules :
    key => try(value["enabled"].backup_aws_sns_topic_arn, null)
  }
}

output "backup_vault_topics" {
  value = { for key, value in local.backup_modules :
    key => try(value["enabled"].backup_vault_lock_sns_topic_arn, null)
  }
}
