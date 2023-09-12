resource "aws_guardduty_detector" "default" {
  #checkov:skip=CKV2_AWS_3: "Ensure GuardDuty is enabled to specific org/region - This will be applied in each account the baseline will run in and in the all supported regions."

  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  tags                         = var.tags
}
