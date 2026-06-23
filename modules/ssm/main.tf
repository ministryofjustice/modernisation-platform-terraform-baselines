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
      cloudWatchEncryptionEnabled = var.session_manager_log_kms_key_id != null
      cloudWatchStreamingEnabled  = true
      s3BucketName                = ""
      s3KeyPrefix                 = ""
      s3EncryptionEnabled         = false
      idleSessionTimeout          = tostring(var.session_manager_idle_timeout_minutes)
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
}
