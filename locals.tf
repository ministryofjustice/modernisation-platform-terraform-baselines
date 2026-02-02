locals {
  enabled           = toset(["enabled"])
  not_enabled       = toset([])
  cloudtrail_bucket = "modernisation-platform-logs-cloudtrail"
  config_bucket     = "modernisation-platform-logs-config"
  workspace_name    = terraform.workspace == "default" ? "modernisation-platform" : terraform.workspace

  mp_owned_workspaces = [
    "cooker-development",
    "example-development",
    "long-term-storage-production",
    "sprinkler-development",
    "testing-test",
    "^core-.*",
    "^modernisation-platform-.*"
  ]

  is_core_or_mp_account = length(regexall(join("|", local.mp_owned_workspaces), terraform.workspace)) > 0

  stream_securityhub_findings = var.enable_securityhub_findings_streaming && local.is_core_or_mp_account
}
