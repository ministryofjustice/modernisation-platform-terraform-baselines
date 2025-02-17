locals {
  enabled           = toset(["enabled"])
  not_enabled       = toset([])
  cloudtrail_bucket = "modernisation-platform-logs-cloudtrail"
  workspace_name    = terraform.workspace == "default" ? "modernisation-platform" : terraform.workspace
}
