data "aws_iam_policy_document" "sechub_forwarding_assume_role" {
  count = local.forward_securityhub_findings ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sechub_forwarding_policy" {
  count = local.forward_securityhub_findings ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["events:PutEvents"]
    resources = [var.central_event_bus_arn]
  }
}

resource "aws_iam_role" "sechub_forwarding" {
  count = local.forward_securityhub_findings ? 1 : 0

  name_prefix        = "SecurityHubForwarding-"
  assume_role_policy = data.aws_iam_policy_document.sechub_forwarding_assume_role[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy" "sechub_forwarding" {
  count = local.forward_securityhub_findings ? 1 : 0

  name   = "SecurityHubForwarding"
  role   = aws_iam_role.sechub_forwarding[0].id
  policy = data.aws_iam_policy_document.sechub_forwarding_policy[0].json
}
