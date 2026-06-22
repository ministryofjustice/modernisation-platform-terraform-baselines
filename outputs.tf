output "session_manager_cloudwatch_logs_policy_arn" {
  description = "ARN of the IAM policy that allows EC2 instance roles to write Session Manager transcript logs to CloudWatch Logs."
  value       = try(module.ssm-baseline-eu-west-1["enabled"].session_manager_cloudwatch_logs_policy_arn, null)
}
