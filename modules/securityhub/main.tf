data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Enable SecurityHub
# Now enabled via organizations

# Enable Standard: AWS Foundational Security Best Practices
resource "aws_securityhub_standards_subscription" "aws-foundational" {
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

# Enable Standard: CIS AWS Foundations
resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}

# Enable Standard: PCI DSS v3.2.1
resource "aws_securityhub_standards_subscription" "pci" {
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/pci-dss/v/3.2.1"
}

# Disabled standard controls - controls that we are not using as we have other mitigating factors in place
# Disable security hub control, security hub currently doesn't cater for SSO log in with MFA from the SSO provider
resource "aws_securityhub_standards_control" "cis_disable_mfa_metric_and_alarm" {
  standards_control_arn = "arn:aws:securityhub:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:control/cis-aws-foundations-benchmark/v/1.2.0/3.2"
  control_status        = "DISABLED"
  disabled_reason       = "MFA from single sign on not supported currently"
  depends_on            = [aws_securityhub_standards_subscription.cis]
}

resource "aws_securityhub_standards_control" "cis_disable_ensure_hardware_mfa_for_root" {
  standards_control_arn = "arn:aws:securityhub:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:control/cis-aws-foundations-benchmark/v/1.2.0/1.14"
  control_status        = "DISABLED"
  disabled_reason       = "Root login actions prevented with SCPs"
  depends_on            = [aws_securityhub_standards_subscription.cis]
}

resource "aws_securityhub_standards_control" "cis_disable_ensure_mfa_for_root" {
  standards_control_arn = "arn:aws:securityhub:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:control/cis-aws-foundations-benchmark/v/1.2.0/1.13"
  control_status        = "DISABLED"
  disabled_reason       = "Root login actions prevented with SCPs"
  depends_on            = [aws_securityhub_standards_subscription.cis]
}

resource "aws_securityhub_standards_control" "aws_disable_ensure_hardware_mfa_for_root" {
  standards_control_arn = "arn:aws:securityhub:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:control/aws-foundational-security-best-practices/v/1.0.0/IAM.6"
  control_status        = "DISABLED"
  disabled_reason       = "Root login actions prevented with SCPs"
  depends_on            = [aws_securityhub_standards_subscription.aws-foundational]
}

resource "aws_securityhub_standards_control" "pci_disable_ensure_hardware_mfa_for_root" {
  standards_control_arn = "arn:aws:securityhub:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:control/pci-dss/v/3.2.1/PCI.IAM.4"
  control_status        = "DISABLED"
  disabled_reason       = "Root login actions prevented with SCPs"
  depends_on            = [aws_securityhub_standards_subscription.pci]
}

resource "aws_securityhub_standards_control" "pci_disable_ensure_mfa_for_root" {
  standards_control_arn = "arn:aws:securityhub:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:control/pci-dss/v/3.2.1/PCI.IAM.5"
  control_status        = "DISABLED"
  disabled_reason       = "Root login actions prevented with SCPs"
  depends_on            = [aws_securityhub_standards_subscription.pci]
}

# SecurityHub Alerting

# Filter for New, High & Critical SecHub findings but exclude Inspector
resource "aws_cloudwatch_event_rule" "sechub_high_and_critical_findings" {
  count       = var.enable_securityhub_alerts ? 1 : 0
  name        = var.sechub_eventbridge_rule_name
  description = "Check for High or Critical Severity SecHub findings"
  event_pattern = jsonencode({
    "source" : ["aws.securityhub"],
    "detail-type" : ["Security Hub Findings - Imported"],
    "detail" : {
      "findings" : {
        "Severity" : {
          "Label" : ["CRITICAL"]
        },
        "Workflow" : {
          "Status" : ["NEW"]
        },
        "ProductFields" : {
          "aws/securityhub/ProductName" : [
            {
              "anything-but" : "Inspector"
            }
          ]
        }
      }
    }
  })
  tags = var.tags
}

# When eventbridge rule is triggered send findings to SNS topic
resource "aws_cloudwatch_event_target" "sechub_findings_sns_topic" {
  count     = var.enable_securityhub_alerts ? 1 : 0
  rule      = aws_cloudwatch_event_rule.sechub_high_and_critical_findings[0].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.sechub_findings_sns_topic[0].arn
}

# Create SNS topic and access policy
resource "aws_sns_topic" "sechub_findings_sns_topic" {
  count             = var.enable_securityhub_alerts ? 1 : 0
  name              = var.sechub_sns_topic_name
  kms_master_key_id = length(aws_kms_key.sns_kms_key) > 0 ? aws_kms_key.sns_kms_key[0].id : null
  tags              = var.tags
}
resource "aws_sns_topic_policy" "sechub_findings_sns_topic" {
  count  = var.enable_securityhub_alerts ? 1 : 0
  arn    = aws_sns_topic.sechub_findings_sns_topic[0].arn
  policy = data.aws_iam_policy_document.sechub_findings_sns_topic_policy[0].json
}

data "aws_iam_policy_document" "sechub_findings_sns_topic_policy" {
  count     = length(aws_sns_topic.sechub_findings_sns_topic) > 0 ? 1 : 0
  policy_id = "sechub findings sns topic policy"

  statement {
    sid    = "Allow topic owner to manage sns topic"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:RemovePermission",
      "sns:SetTopicAttributes",
      "sns:DeleteTopic",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes",
      "sns:AddPermission",
      "sns:Subscribe"
    ]
    resources = [
      aws_sns_topic.sechub_findings_sns_topic[0].arn
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        data.aws_caller_identity.current.account_id
      ]
    }
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
  }
  statement {
    sid    = "Allow eventbridge to publish messages to sns topic"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.sechub_findings_sns_topic[0].arn
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }
  }
}

# Create CMK to encrypt SNS topic
resource "aws_kms_key" "sns_kms_key" {
  bypass_policy_lockout_safety_check = false
  count                              = var.enable_securityhub_alerts ? 1 : 0
  description                        = "KMS key for SNS topic encryption"
  enable_key_rotation                = true
  policy                             = data.aws_iam_policy_document.sns_kms.json
  tags                               = var.tags
}

resource "aws_kms_alias" "sns_kms_alias" {
  count         = var.enable_securityhub_alerts ? 1 : 0
  name_prefix   = var.sechub_sns_kms_key_name
  target_key_id = aws_kms_key.sns_kms_key[0].id
}

# Static code analysis ignores:
# - CKV_AWS_109 and CKV_AWS_111: Ignore warnings regarding resource = ["*"]. See https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
#   Specifically: "In a key policy, the value of the Resource element is "*", which means "this KMS key." The asterisk ("*") identifies the KMS key to which the key policy is attached."
data "aws_iam_policy_document" "sns_kms" {
  # checkov:skip=CKV_AWS_109: "Key policy requires asterisk resource - see note above"
  # checkov:skip=CKV_AWS_111: "Key policy requires asterisk resource - see note above"
  # checkov:skip=CKV_AWS_356: "Key policy requires asterisk resource - see note above"

  statement {
    sid    = "Allow management access of the key to the owning account"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
  statement {
    sid     = "Allow SNS and Eventbridge services to use the key"
    effect  = "Allow"
    actions = ["kms:*"]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

# Setup PagerDuty Alerting in eu-west-2 region
module "pagerduty_alerts_securityhub" {
  count = var.enable_securityhub_alerts ? 1 : 0
  depends_on = [
    aws_sns_topic.sechub_findings_sns_topic
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=0179859e6fafc567843cd55c0b05d325d5012dc4" # v2.0.0
  sns_topics                = [aws_sns_topic.sechub_findings_sns_topic[0].name]
  pagerduty_integration_key = var.pagerduty_integration_key
}