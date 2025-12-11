output "sechub_eventbridge_rule_arns" {
  description = "The ARNs of the SecurityHub EventBridge rules"
  value       = module.securityhub-test.sechub_eventbridge_rule_arns
}
output "sechub_sns_topic_arn" {
  description = "The ARN of the SecurityHub SNS topic"
  value       = module.securityhub-test.sechub_sns_topic_arn
}

output "sechub_sns_kms_key_arn" {
  description = "The ARN of the SecurityHub SNS Topic KMS key"
  value       = module.securityhub-test.sechub_sns_kms_key_arn
}