output "aws_backup_vault_arn" {
  value = aws_backup_vault.default.arn
}

output "aws_backup_plan_production" {
  value = aws_backup_plan.default.arn
}

output "aws_backup_plan_non_production" {
  value = aws_backup_plan.non_production.arn
}

output "aws_backup_selection_production" {
  value = aws_backup_selection.production.id
}

output "aws_backup_selection_non_production" {
  value = aws_backup_selection.non_production.id
}
output "backup_aws_sns_topic_arn" {
  value = length(aws_sns_topic.backup_failure_topic) > 0 ? aws_sns_topic.backup_failure_topic[0].arn : ""
}

output "aws_backup_plan_non_production_rule" {
  value = aws_backup_plan.non_production.rule
}

output "backup_vault_lock_sns_topic_name" {
  value = length(aws_sns_topic.backup_vault_topic) > 0 ? aws_sns_topic.backup_vault_topic[0].arn : ""
}

