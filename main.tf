module "cloudtrail" {
  source = "./modules/cloudtrail"
  tags   = var.tags
}

module "securityhub-alarms" {
  source = "./modules/securityhub-alarms"
  tags   = var.tags
}
