# tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "iam_credential_alert" {
  #checkov:skip=CKV_AWS_26:"encrypted topics do not work with pagerduty subscription"
  name = "iam-credential-exposed-alert"
  tags = var.tags
}

module "pagerduty_iam_credential_alert" {
  depends_on = [
    aws_sns_topic.iam_credential_alert
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=d88bd90d490268896670a898edfaba24bba2f8ab" # v3.0.0
  sns_topics                = [aws_sns_topic.iam_credential_alert.name]
  pagerduty_integration_key = var.pagerduty_integration_key
}

resource "aws_cloudwatch_event_rule" "iam_credential_exposed" {
  name        = "iam-credential-exposed"
  description = "Triggers on AWS_RISK_CREDENTIALS_EXPOSED Health events"
  tags        = var.tags

  event_pattern = jsonencode({
    source      = ["aws.health"]
    detail-type = ["AWS Health Event"]
    detail = {
      service       = ["IAM"]
      eventTypeCode = ["AWS_RISK_CREDENTIALS_EXPOSED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "iam_credential_exposed_lambda" {
  rule      = aws_cloudwatch_event_rule.iam_credential_exposed.name
  target_id = "credential-responder-lambda"
  arn       = aws_lambda_function.credential_responder.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.credential_responder.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.iam_credential_exposed.arn
}

resource "aws_iam_role" "credential_responder" {
  name = var.credential_responder_role_name
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "credential_responder" {
  name = "credential-responder-policy"
  role = aws_iam_role.credential_responder.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DisableAndQuarantineIAM"
        Effect = "Allow"
        Action = [
          "iam:UpdateAccessKey",
          "iam:PutUserPolicy",
          "iam:ListAccessKeys"
        ]
        Resource = "arn:aws:iam::*:user/*"
      },
      {
        Sid      = "ListUsersForKeyLookup"
        Effect   = "Allow"
        Action   = ["iam:ListUsers"]
        Resource = "*"
      },
      {
        Sid      = "PublishToSNS"
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.iam_credential_alert.arn
      },
      {
        Sid    = "BasicLambdaLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_lambda_function" "credential_responder" {
  function_name    = var.credential_responder_lambda_name
  description      = "Disables exposed IAM keys, quarantines users, and raises alerts via SNS"
  role             = aws_iam_role.credential_responder.arn
  handler          = "credential_responder.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.credential_responder.output_path
  source_code_hash = data.archive_file.credential_responder.output_base64sha256
  timeout          = 60
  tags             = var.tags

  environment {
    variables = {
      CREDENTIAL_ALERT_SNS_ARN = aws_sns_topic.iam_credential_alert.arn
    }
  }
}

data "archive_file" "credential_responder" {
  type        = "zip"
  source_file = "${path.module}/lambda/credential_responder.py"
  output_path = "${path.module}/lambda/credential_responder.zip"
}
