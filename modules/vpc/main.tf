# Configure default AWS VPC resources to comply with SecurityHub standards
## VPC
# Default VPC presently defined in code so it can be managed through code
# tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "default" {
  tags = var.tags
}

## Route Table
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_default_vpc.default.default_route_table_id
  tags                   = var.tags
}

## Network ACL
## Terraform mentions you should ignore subnet_ids for aws_default_network_acl
## because subnets always need to be associated with something, and if they're
## not explicitly set, they will show up as a change
## See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl#managing-subnets-in-the-default-network-acl
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_default_vpc.default.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

## DHCP options
resource "aws_default_vpc_dhcp_options" "default" {
  tags = var.tags
}

## Security Group
resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id
  tags   = var.tags
}

# VPC Flow Logs
## CloudWatch log group for VPC Flow Logs
# tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "default-vpc-flow-logs" {
  name = "default-vpc-flow-logs"
  retention_in_days = var.retention_days
  tags = var.tags
}

## Enable VPC Flow Logs for the default VPC
resource "aws_flow_log" "default-vpc-flow-logs" {
  log_destination = aws_cloudwatch_log_group.default-vpc-flow-logs.arn
  traffic_type    = "ALL"
  iam_role_arn    = var.iam_role_arn
  vpc_id          = aws_default_vpc.default.id
  tags            = var.tags
}
