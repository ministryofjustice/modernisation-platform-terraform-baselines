data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  enable_session_manager_log_forwarding = var.enable_session_manager_logging && var.session_manager_log_forwarding_destination_arn != null
  session_manager_log_destination_resource_arn = (
    var.session_manager_log_forwarding_destination_arn == null
    ? null
    : replace(var.session_manager_log_forwarding_destination_arn, ":destination:", ":destination/")
  )
}

resource "aws_ssm_service_setting" "disable_public_sharing" {
  setting_id    = "/ssm/documents/console/public-sharing-permission"
  setting_value = "Disable"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [setting_id]
  }
}

resource "aws_cloudwatch_log_group" "session_manager" {
  count = var.enable_session_manager_logging ? 1 : 0

  name              = "session-manager-logs"
  retention_in_days = var.session_manager_log_retention_in_days
  kms_key_id        = var.session_manager_log_kms_key_id
  tags              = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ssm_document" "session_manager_run_shell" {
  count = var.enable_session_manager_logging ? 1 : 0

  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Document to hold regional settings for Session Manager"
    sessionType   = "Standard_Stream"

    inputs = {
      cloudWatchLogGroupName      = aws_cloudwatch_log_group.session_manager[0].name
      cloudWatchEncryptionEnabled = false
      cloudWatchStreamingEnabled  = true
      s3BucketName                = ""
      s3KeyPrefix                 = ""
      s3EncryptionEnabled         = false
      idleSessionTimeout          = tostring(var.session_manager_idle_timeout_minutes)
      maxSessionDuration          = "720"
      kmsKeyId                    = ""
      runAsEnabled                = false
      runAsDefaultUser            = ""

      shellProfile = {
        windows = ""
        linux   = ""
      }
    }
  })

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role" "session_manager_logs_to_core_logging" {
  count = local.enable_session_manager_log_forwarding ? 1 : 0

  name = "CWLtoCoreLoggingSessionManager"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "logs.${data.aws_region.current.region}.amazonaws.com"
      },
      Action = "sts:AssumeRole",
      Condition = {
        StringLike = {
          "aws:SourceArn" = [
            "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"
          ]
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "session_manager_logs_to_core_logging" {
  count = local.enable_session_manager_log_forwarding ? 1 : 0

  name = "Permissions-Policy-For-CWL-SessionManager"
  role = aws_iam_role.session_manager_logs_to_core_logging[0].name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["logs:PutSubscriptionFilter"],
      Resource = local.session_manager_log_destination_resource_arn
    }]
  })
}

resource "aws_cloudwatch_log_subscription_filter" "session_manager_logs_to_core_logging" {
  count = local.enable_session_manager_log_forwarding ? 1 : 0

  name            = "session-manager-logs-to-core-logging"
  log_group_name  = aws_cloudwatch_log_group.session_manager[0].name
  filter_pattern  = ""
  destination_arn = var.session_manager_log_forwarding_destination_arn
  role_arn        = aws_iam_role.session_manager_logs_to_core_logging[0].arn

  depends_on = [
    aws_cloudwatch_log_group.session_manager,
    aws_iam_role_policy.session_manager_logs_to_core_logging
  ]
}
