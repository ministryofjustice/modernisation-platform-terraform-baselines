resource "aws_guardduty_detector" "default" {

  #checkov:skip=CKV2_AWS_3: "Ensure GuardDuty is enabled to specific org/region"

  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  tags                         = var.tags
}
