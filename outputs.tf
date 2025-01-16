output "backup_failure_topics" {
  value = {
    "ap-northeast-1" = try(module.backup-ap-northeast-1["enabled"].backup_aws_sns_topic_arn, null)
    "ap-northeast-2" = try(module.backup-ap-northeast-2["enabled"].backup_aws_sns_topic_arn, null)
    "ap-south-1"     = try(module.backup-ap-south-1["enabled"].backup_aws_sns_topic_arn, null)
    "ap-southeast-1" = try(module.backup-ap-southeast-1["enabled"].backup_aws_sns_topic_arn, null)
    "ap-southeast-2" = try(module.backup-ap-southeast-2["enabled"].backup_aws_sns_topic_arn, null)
    "ca-central-1"   = try(module.backup-ca-central-1["enabled"].backup_aws_sns_topic_arn, null)
    "eu-central-1"   = try(module.backup-eu-central-1["enabled"].backup_aws_sns_topic_arn, null)
    "eu-north-1"     = try(module.backup-eu-north-1["enabled"].backup_aws_sns_topic_arn, null)
    "eu-west-1"      = try(module.backup-eu-west-1["enabled"].backup_aws_sns_topic_arn, null)
    "eu-west-2"      = try(module.backup-eu-west-2["enabled"].backup_aws_sns_topic_arn, null)
    "eu-west-3"      = try(module.backup-eu-west-3["enabled"].backup_aws_sns_topic_arn, null)
    "sa-east-1"      = try(module.backup-sa-east-1["enabled"].backup_aws_sns_topic_arn, null)
    "us-east-1"      = try(module.backup-us-east-1["enabled"].backup_aws_sns_topic_arn, null)
    "us-east-2"      = try(module.backup-us-east-2["enabled"].backup_aws_sns_topic_arn, null)
    "us-west-1"      = try(module.backup-us-west-1["enabled"].backup_aws_sns_topic_arn, null)
    "us-west-2"      = try(module.backup-us-west-2["enabled"].backup_aws_sns_topic_arn, null)
  }
}

output "backup_vault_topics" {
  value = {
    "ap-northeast-1" = try(module.backup-ap-northeast-1["enabled"].backup_vault_lock_sns_topic_arn, null)
    "ap-northeast-2" = try(module.backup-ap-northeast-2["enabled"].backup_vault_lock_sns_topic_arn, null)
    "ap-south-1"     = try(module.backup-ap-south-1["enabled"].backup_vault_lock_sns_topic_arn, null)
    "ap-southeast-1" = try(module.backup-ap-southeast-1["enabled"].backup_vault_lock_sns_topic_arn, null)
    "ap-southeast-2" = try(module.backup-ap-southeast-2["enabled"].backup_vault_lock_sns_topic_arn, null)
    "ca-central-1"   = try(module.backup-ca-central-1["enabled"].backup_vault_lock_sns_topic_arn, null)
    "eu-central-1"   = try(module.backup-eu-central-1["enabled"].backup_vault_lock_sns_topic_arn, null)
    "eu-north-1"     = try(module.backup-eu-north-1["enabled"].backup_vault_lock_sns_topic_arn, null)
    "eu-west-1"      = try(module.backup-eu-west-1["enabled"].backup_vault_lock_sns_topic_arn, null)
    "eu-west-2"      = try(module.backup-eu-west-2["enabled"].backup_vault_lock_sns_topic_arn, null)
    "eu-west-3"      = try(module.backup-eu-west-3["enabled"].backup_vault_lock_sns_topic_arn, null)
    "sa-east-1"      = try(module.backup-sa-east-1["enabled"].backup_vault_lock_sns_topic_arn, null)
    "us-east-1"      = try(module.backup-us-east-1["enabled"].backup_vault_lock_sns_topic_arn, null)
    "us-east-2"      = try(module.backup-us-east-2["enabled"].backup_vault_lock_sns_topic_arn, null)
    "us-west-1"      = try(module.backup-us-west-1["enabled"].backup_vault_lock_sns_topic_arn, null)
    "us-west-2"      = try(module.backup-us-west-2["enabled"].backup_vault_lock_sns_topic_arn, null)
  }
}
