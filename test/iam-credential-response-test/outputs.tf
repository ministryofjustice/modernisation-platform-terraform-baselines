output "sns_topic_arn" {
  value = module.iam-credential-response-test.sns_topic_arn
}

output "lambda_function_arn" {
  value = module.iam-credential-response-test.lambda_function_arn
}

output "lambda_role_arn" {
  value = module.iam-credential-response-test.lambda_role_arn
}

output "eventbridge_rule_arn" {
  value = module.iam-credential-response-test.eventbridge_rule_arn
}