provider "aws" {
  region = "eu-west-2"
}

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies for the Lambda function
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "ssm:GetParameter",
          "ecs:ListClusters",
          "ecs:ListContainerInstances",
          "ecs:DescribeContainerInstances",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "ec2:DescribeInstances",
          "sns:Publish"
        ],
        Resource : "*"
      }
    ]
  })
}

# SNS Topic for Notifications
resource "aws_sns_topic" "outdated_ami_notifications" {
  name = "OutdatedAmiNotifications"
}

# SNS Email Subscription for Notifications
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.outdated_ami_notifications.arn
  protocol  = "email"
  endpoint  = "khatra.farah@digital.justice.gov.uk"
}

# Lambda Function for Outdated AMI Monitoring
resource "aws_lambda_function" "check_outdated_amis" {
  function_name = "CheckOutdatedAMIs"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = "lambda_function.zip" # Assumes you've zipped the Python function
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.outdated_ami_notifications.arn
      REGION        = "eu-west-2" # Environment variable for region
    }
  }
}

# CloudWatch EventBridge Rule for Daily Execution
resource "aws_cloudwatch_event_rule" "daily_schedule" {
  name                = "DailyOutdatedAmiCheck"
  schedule_expression = "rate(1 day)"
}

# EventBridge Target for Lambda
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_schedule.name
  target_id = "CheckOutdatedAMIs"
  arn       = aws_lambda_function.check_outdated_amis.arn
}

# Grant Permission for EventBridge to Invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.check_outdated_amis.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_schedule.arn
}
