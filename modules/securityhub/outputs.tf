output "sechub_eventbridge_rule_arn" {
  description = "The ARN of the SecurityHub EventBridge rule"
  value       = aws_cloudwatch_event_rule.sechub_high_and_critical_findings.arn
}
output "sechub_sns_topic_arn" {
  description = "The ARN of the SecurityHub SNS topic"
  value       = aws_sns_topic.sechub_findings_sns_topic.arn
}

output "sechub_sns_kms_key_arn" {
  description = "The ARN of the SecurityHub SNS Topic KMS key"
  value       = aws_kms_key.sns_kms_key[0].arn
}
