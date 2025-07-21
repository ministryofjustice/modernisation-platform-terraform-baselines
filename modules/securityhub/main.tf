data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Enable SecurityHub
# Now enabled via organizations

# Enable Standard: AWS Foundational Security Best Practices
resource "aws_securityhub_standards_subscription" "aws-foundational" {
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

# Enable Standard: CIS AWS Foundations
resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}

# Enable Standard: PCI DSS v3.2.1
resource "aws_securityhub_standards_subscription" "pci" {
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.region}::standards/pci-dss/v/3.2.1"
}

# Disabled standard controls - controls that we are not using as we have other mitigating factors in place
# Disable security hub control, security hub currently doesn't cater for SSO log in with MFA from the SSO provider
resource "aws_securityhub_standards_control" "cis_disable_mfa_metric_and_alarm" {
  standards_control_arn = "arn:aws:securityhub:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:control/cis-aws-foundations-benchmark/v/1.2.0/3.2"
  control_status        = "DISABLED"
  disabled_reason       = "MFA from single sign on not supported currently"
  depends_on            = [aws_securityhub_standards_subscription.cis]
}

resource "aws_securityhub_standards_control" "cis_disable_ensure_hardware_mfa_for_root" {
  standards_control_arn = "arn:aws:securityhub:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:control/cis-aws-foundations-benchmark/v/1.2.0/1.14"
  control_status        = "DISABLED"
  disabled_reason       = "Root login actions prevented with SCPs"
  depends_on            = [aws_securityhub_standards_subscription.cis]
}

resource "aws_securityhub_standards_control" "cis_disable_ensure_mfa_for_root" {
  standards_control_arn = "arn:aws:securityhub:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:control/cis-aws-foundations-benchmark/v/1.2.0/1.13"
  control_status        = "DISABLED"
  disabled_reason       = "Root login actions prevented with SCPs"
  depends_on            = [aws_securityhub_standards_subscription.cis]
}

resource "aws_securityhub_standards_control" "aws_disable_ensure_hardware_mfa_for_root" {
  standards_control_arn = "arn:aws:securityhub:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:control/aws-foundational-security-best-practices/v/1.0.0/IAM.6"
  control_status        = "DISABLED"
  disabled_reason       = "Root login actions prevented with SCPs"
  depends_on            = [aws_securityhub_standards_subscription.aws-foundational]
}

resource "aws_securityhub_standards_control" "pci_disable_ensure_hardware_mfa_for_root" {
  standards_control_arn = "arn:aws:securityhub:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:control/pci-dss/v/3.2.1/PCI.IAM.4"
  control_status        = "DISABLED"
  disabled_reason       = "Root login actions prevented with SCPs"
  depends_on            = [aws_securityhub_standards_subscription.pci]
}

resource "aws_securityhub_standards_control" "pci_disable_ensure_mfa_for_root" {
  standards_control_arn = "arn:aws:securityhub:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:control/pci-dss/v/3.2.1/PCI.IAM.5"
  control_status        = "DISABLED"
  disabled_reason       = "Root login actions prevented with SCPs"
  depends_on            = [aws_securityhub_standards_subscription.pci]
}

