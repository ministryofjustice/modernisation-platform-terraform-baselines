module "support-test" {
  source = "../../modules/support"
  role_name = var.role_name
  tags   = local.tags
}