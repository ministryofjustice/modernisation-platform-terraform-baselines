locals {
  findings_stream_scope = toset([
    for severity in var.securityhub_slack_alerts_scope : upper(severity)
    if contains(["CRITICAL", "HIGH"], upper(severity))
  ])

  stream_findings = var.enable_securityhub_findings_streaming && length(local.findings_stream_scope) > 0

  findings_rule_scope = var.enable_securityhub_slack_alerts ? toset(var.securityhub_slack_alerts_scope) : (
    local.stream_findings ? local.findings_stream_scope : toset([])
  )

  publish_findings_metrics = local.stream_findings && var.enable_securityhub_findings_metrics
}
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

# SecurityHub Alerting 

# Filter for New SecHub findings by severity level (one rule per severity)
resource "aws_cloudwatch_event_rule" "sechub_findings" {
  for_each    = local.findings_rule_scope
  name        = "${var.sechub_eventbridge_rule_name}_${lower(each.value)}"
  description = "Check for ${each.value} Severity Security Hub findings"
  event_pattern = jsonencode({
    "source" : ["aws.securityhub"],
    "detail-type" : ["Security Hub Findings - Imported"],
    "detail" : {
      "findings" : {
        "Severity" : {
          "Label" : [each.value]
        },
        "Workflow" : {
          "Status" : ["NEW"]
        }
      }
    }
  })
  tags = var.tags
}

# When eventbridge rule is triggered send findings to SNS topic
resource "aws_cloudwatch_event_target" "sechub_findings_sns_topic" {
  for_each  = var.enable_securityhub_slack_alerts ? toset(var.securityhub_slack_alerts_scope) : []
  rule      = aws_cloudwatch_event_rule.sechub_findings[each.key].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.sechub_findings_sns_topic[0].arn
}

# Forward Security Hub findings into CloudWatch Logs so we can build dashboards in core accounts.
resource "aws_cloudwatch_log_group" "sechub_findings" {
  count             = local.stream_findings ? 1 : 0
  name              = "/aws/events/securityhub-findings"
  retention_in_days = 90
  tags              = var.tags
}

resource "aws_cloudwatch_log_resource_policy" "sechub_findings_eventbridge" {
  count       = local.stream_findings ? 1 : 0
  policy_name = "AllowEventBridgeToPutFindings"
  policy_document = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowEventBridgePutLogs",
        "Effect" : "Allow",
        "Principal" : { "Service" : "events.amazonaws.com" },
        "Action" : [
          "logs:PutLogEvents",
          "logs:CreateLogStream"
        ],
        "Resource" : "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/events/securityhub-findings:*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_metric_filter" "sechub_findings" {
  for_each = local.publish_findings_metrics ? toset(local.findings_stream_scope) : []

  name           = "securityhub_${lower(each.value)}_findings_count"
  log_group_name = aws_cloudwatch_log_group.sechub_findings[0].name
  pattern        = "{ $.detail.findings[*].Severity.Label = \"${each.value}\" }"

  metric_transformation {
    name      = "SecurityHub${each.value}Findings"
    namespace = var.securityhub_findings_metric_namespace
    value     = "1"
    dimensions = {
      Severity  = "$.detail.findings[0].Severity.Label"
      AccountId = "$.account"
      Region    = "$.region"
    }
    unit = "Count"
  }
}

resource "aws_cloudwatch_event_target" "sechub_findings_log_group" {
  for_each  = local.stream_findings ? toset(local.findings_stream_scope) : []
  rule      = aws_cloudwatch_event_rule.sechub_findings[each.key].name
  target_id = "SendToCloudWatchLogs-${lower(each.value)}"
  arn       = aws_cloudwatch_log_group.sechub_findings[0].arn
}

# Create SNS topic and access policy
resource "aws_sns_topic" "sechub_findings_sns_topic" {
  count             = var.enable_securityhub_slack_alerts ? 1 : 0
  name              = var.sechub_sns_topic_name
  kms_master_key_id = length(aws_kms_key.sns_kms_key) > 0 ? aws_kms_key.sns_kms_key[0].id : null
  tags              = var.tags
}
resource "aws_sns_topic_policy" "sechub_findings_sns_topic" {
  count  = var.enable_securityhub_slack_alerts ? 1 : 0
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
  count                              = var.enable_securityhub_slack_alerts ? 1 : 0
  description                        = "KMS key for SNS topic encryption"
  enable_key_rotation                = true
  policy                             = data.aws_iam_policy_document.sns_kms.json
  tags                               = var.tags
}

resource "aws_kms_alias" "sns_kms_alias" {
  count         = var.enable_securityhub_slack_alerts ? 1 : 0
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
  count = var.enable_securityhub_slack_alerts ? 1 : 0
  depends_on = [
    aws_sns_topic.sechub_findings_sns_topic
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=d88bd90d490268896670a898edfaba24bba2f8ab" # v3.0.0
  sns_topics                = [aws_sns_topic.sechub_findings_sns_topic[0].name]
  pagerduty_integration_key = var.pagerduty_integration_key
}
