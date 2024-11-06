output "sechub_eventbridge_rule_arn" {
  description = "The ARN of the SecurityHub EventBridge rule"
  value       = length(aws_cloudwatch_event_rule.sechub_high_and_critical_findings) > 0 ? aws_cloudwatch_event_rule.sechub_high_and_critical_findings[0].arn : null
}

output "sechub_sns_topic_arn" {
  description = "The ARN of the SecurityHub SNS topic"
  value       = length(aws_sns_topic.sechub_findings_sns_topic) > 0 ? aws_sns_topic.sechub_findings_sns_topic[0].arn : null
}

output "sechub_sns_kms_key_arn" {
  description = "The ARN of the SecurityHub SNS Topic KMS key"
  value       = length(aws_kms_key.sns_kms_key) > 0 ? aws_kms_key.sns_kms_key[0].arn : null
}
