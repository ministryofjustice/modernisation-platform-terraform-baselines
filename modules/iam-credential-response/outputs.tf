output "sns_topic_arn" {
  value       = aws_sns_topic.iam_credential_alert.arn
  description = "ARN of the IAM credential alert SNS topic"
}

output "lambda_function_arn" {
  value       = aws_lambda_function.credential_responder.arn
  description = "ARN of the IAM credential responder Lambda function"
}

output "lambda_role_arn" {
  value       = aws_iam_role.credential_responder.arn
  description = "ARN of the IAM role used by the credential responder Lambda"
}

output "eventbridge_rule_arn" {
  value       = aws_cloudwatch_event_rule.iam_credential_exposed.arn
  description = "ARN of the EventBridge rule that triggers the credential responder"
}