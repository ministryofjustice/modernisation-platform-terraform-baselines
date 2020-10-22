module "cloudtrail" {
  source = "./modules/cloudtrail"
  tags   = var.tags
}

module "support" {
  source = "./modules/support"
  tags   = var.tags
}
