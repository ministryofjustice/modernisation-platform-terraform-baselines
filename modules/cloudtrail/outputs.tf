output "cloudwatch_log_group_arn" {
  value       = aws_cloudwatch_log_group.cloudtrail.arn
  description = "CloudTrail CloudWatch log group ARN"
}

# output "log_bucket" {
#   value       = module.cloudtrail-log-bucket.bucket
#   description = "Direct aws_s3_bucket resource with all attributes"
# }

# output "s3_bucket" {
#   value       = module.cloudtrail-bucket.bucket
#   description = "Direct aws_s3_bucket resource with all attributes"
# }

output "sns_topic_arn" {
  value       = aws_sns_topic.cloudtrail.arn
  description = "CloudTrail SNS topic ARN"
}

output "cloudtrail_arn" {
  value = aws_cloudtrail.cloudtrail.arn
}

output "cloudtrail_role_arn" {
  value = aws_iam_role.cloudtrail.arn
}

output "cloudwatch_log_stream_arn" {
  value = aws_cloudwatch_log_stream.cloudtrail-stream.arn
}

output "sns_topic_policy_arn" {
  value = aws_sns_topic_policy.cloudtrail.arn
}

output "cloudtrail_policy_arn" {
  value = aws_iam_policy.cloudtrail.arn
}