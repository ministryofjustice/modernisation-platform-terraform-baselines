output "session_manager_cloudwatch_logs_policy_arn" {
  description = "ARN of the IAM policy that allows EC2 instance roles to write Session Manager transcript logs to CloudWatch Logs."
  value       = try(aws_iam_policy.session_manager_cloudwatch_logs[0].arn, null)
}
