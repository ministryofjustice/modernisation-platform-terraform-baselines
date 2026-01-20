output "sechub_eventbridge_rule_arns" {
  description = "The ARNs of the SecurityHub EventBridge rules"
  value       = { for k, v in aws_cloudwatch_event_rule.sechub_findings : k => v.arn }
}

output "sechub_sns_topic_arn" {
  description = "The ARN of the SecurityHub SNS topic"
  value       = length(aws_sns_topic.sechub_findings_sns_topic) > 0 ? aws_sns_topic.sechub_findings_sns_topic[0].arn : null
}

output "sechub_sns_kms_key_arn" {
  description = "The ARN of the SecurityHub SNS Topic KMS key"
  value       = length(aws_kms_key.sns_kms_key) > 0 ? aws_kms_key.sns_kms_key[0].arn : null
}