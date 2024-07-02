output "aws_backup_vault_arn" {
  value = module.backup-test.aws_backup_vault_arn
}

output "aws_backup_plan_production" {
  value = module.backup-test.aws_backup_plan_production
}

output "aws_backup_plan_non_production" {
  value = module.backup-test.aws_backup_plan_non_production
}

output "aws_backup_selection_production" {
  value = module.backup-test.aws_backup_selection_production
}

output "aws_backup_selection_non_production" {
  value = module.backup-test.aws_backup_selection_non_production
}

output "backup_aws_sns_topic_arn" {
  value = module.backup-test.backup_aws_sns_topic_arn
}

output "aws_backup_plan_non_production_rule" {
  value = module.backup-test.aws_backup_plan_non_production_rule
}