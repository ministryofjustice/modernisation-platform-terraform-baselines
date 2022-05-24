# Configure default AWS VPC resources to comply with SecurityHub standards
# Most default VPC resources are now deleted on account creation
## DHCP options
resource "aws_default_vpc_dhcp_options" "default" {
  tags = var.tags
}
