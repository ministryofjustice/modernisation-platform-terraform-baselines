data "aws_iam_policy_document" "sechub_forwarding_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sechub_forwarding_role" {
  count              = var.enable_securityhub_event_forwarding && var.central_event_bus_arn != "" ? 1 : 0
  name               = "sechub-forward-to-central-bus"
  assume_role_policy = data.aws_iam_policy_document.sechub_forwarding_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "sechub_forwarding_policy" {
  count = var.enable_securityhub_event_forwarding && var.central_event_bus_arn != "" ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["events:PutEvents"]
    resources = [var.central_event_bus_arn]
  }
}

resource "aws_iam_role_policy" "sechub_forwarding_role_policy" {
  count  = var.enable_securityhub_event_forwarding && var.central_event_bus_arn != "" ? 1 : 0
  name   = "sechub-forward-to-central-bus"
  role   = aws_iam_role.sechub_forwarding_role[0].id
  policy = data.aws_iam_policy_document.sechub_forwarding_policy[0].json
}

resource "aws_cloudwatch_event_target" "sechub_findings_central_bus" {
  for_each = var.enable_securityhub_slack_alerts && var.enable_securityhub_event_forwarding && var.central_event_bus_arn != "" ? toset(var.securityhub_slack_alerts_scope) : []

  rule      = aws_cloudwatch_event_rule.sechub_findings[each.key].name
  target_id = "ForwardToCentralEventBus"
  arn       = var.central_event_bus_arn
  role_arn  = aws_iam_role.sechub_forwarding_role[0].arn
}