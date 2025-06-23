locals {
  enabled           = toset(["enabled"])
  not_enabled       = toset([])
  cloudtrail_bucket = "modernisation-platform-logs-cloudtrail"
  config_bucket     = "modernisation-platform-logs-config"
  workspace_name    = terraform.workspace == "default" ? "modernisation-platform" : terraform.workspace
}
