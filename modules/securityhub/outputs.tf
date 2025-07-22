output "aws_foundational_standard_subscription_id" {
  value = aws_securityhub_standards_subscription.aws-foundational.id
}

output "cis_standard_subscription_id" {
  value = aws_securityhub_standards_subscription.cis.id
}

output "pci_standard_subscription_id" {
  value = aws_securityhub_standards_subscription.pci.id
}