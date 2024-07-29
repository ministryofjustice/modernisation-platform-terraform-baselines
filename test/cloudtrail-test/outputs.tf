output "cloudtrail_arn" {
  value = module.cloudtrail-test.cloudtrail_arn
}

output "cloudtrail_role_arn" {
  value = module.cloudtrail-test.cloudtrail_role_arn
}

output "cloudtrail_policy_arn" {
  value = module.cloudtrail-test.cloudtrail_policy_arn
}

output "cloudwatch_log_group_arn"{
  value = module.cloudtrail-test.cloudwatch_log_group_arn
}

output "cloudwatch_log_stream_arn" {
  value = module.cloudtrail-test.cloudwatch_log_stream_arn
}

output "sns_topic_arn" {
  value = module.cloudtrail-test.sns_topic_arn
}

output "sns_topic_policy_arn" {
  value = module.cloudtrail-test.sns_topic_policy_arn
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.cloudtrail_s3_bucket.arn
}

output "s3_policy_attachment" {
  value = aws_s3_bucket_policy.s3_cloudtrail_policy.bucket
}