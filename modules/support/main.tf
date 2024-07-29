data "aws_caller_identity" "current" {}

# Create an IAM role for AWS Support service access
resource "aws_iam_role" "support" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
  tags               = var.tags
}

data "aws_iam_policy_document" "assume-role-policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "support" {
  role       = aws_iam_role.support.id
  policy_arn = "arn:aws:iam::aws:policy/AWSSupportAccess"
}
