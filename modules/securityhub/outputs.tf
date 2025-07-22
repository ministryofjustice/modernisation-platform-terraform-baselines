output "aws_foundational_standard_subscription_arn" {
  description = "ARN of the AWS Foundational Security Best Practices standard subscription"
  value       = aws_securityhub_standards_subscription.aws-foundational.arn
}

output "cis_standard_subscription_arn" {
  description = "ARN of the CIS AWS Foundations Benchmark standard subscription"
  value       = aws_securityhub_standards_subscription.cis.arn
}

output "pci_standard_subscription_arn" {
  description = "ARN of the PCI DSS standard subscription"
  value       = aws_securityhub_standards_subscription.pci.arn
}