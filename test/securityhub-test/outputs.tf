output "sechub_eventbridge_rule_arn" {
  description = "The ARN of the SecurityHub EventBridge rule"
  value       = module.securityhub-test.sechub_eventbridge_rule_arn
}
output "sechub_sns_topic_arn" {
  description = "The ARN of the SecurityHub SNS topic"
  value       = module.securityhub-test.sechub_sns_topic_arn
}

output "sechub_sns_kms_key_arn" {
  description = "The ARN of the SecurityHub SNS Topic KMS key"
  value       = module.securityhub-test.sechub_sns_kms_key_arn
}
