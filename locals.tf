locals {
  enabled           = toset(["enabled"])
  not_enabled       = toset([])
  cloudtrail_bucket = "modernisation-platform-logs-cloudtrail"
  account_alias     = data.aws_iam_account_alias.current.account_alias
}
