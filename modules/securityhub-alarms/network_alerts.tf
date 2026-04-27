# 3.10 - Ensure a log metric filter and alarm exist for security group changes
resource "aws_cloudwatch_log_metric_filter" "security-group-changes" {
  for_each       = toset(local.security_group_change_event_names)
  name           = "${var.security_group_changes_metric_filter_name}-${each.key}"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"

  metric_transformation {
    name      = var.security_group_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "security-group-changes" {
  alarm_name        = var.security_group_changes_alarm_name
  alarm_description = "Monitors for AWS EC2 Security Group changes."
  alarm_actions     = local.low_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.security_group_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.11 - Ensure a log metric filter and alarm exist for changes to Network Access Control Lists (NACL)
resource "aws_cloudwatch_log_metric_filter" "nacl-changes" {
  for_each       = toset(local.nacl_unauthorised_event_names)
  name           = "${var.nacl_changes_metric_filter_name}-${each.key}"
  pattern        = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.nacl_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "nacl-changes" {
  alarm_name        = var.nacl_changes_alarm_name
  alarm_description = "Monitors for AWS EC2 Network Access Control Lists changes."
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.nacl_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.12 - Ensure a log metric filter and alarm exist for changes to network gateways, including Transit Gateways
resource "aws_cloudwatch_log_metric_filter" "network-gateway-changes" {
  for_each       = toset(local.ngw_unauthorised_event_names)
  name           = "${var.network_gateway_changes_metric_filter_name}-${each.key}"
  pattern        = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.network_gateway_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "network-gateway-changes" {
  alarm_name        = var.network_gateway_changes_alarm_name
  alarm_description = "Monitors for AWS EC2 network gateway changes."
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.network_gateway_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.13 - Ensure a log metric filter and alarm exist for route table changes
resource "aws_cloudwatch_log_metric_filter" "route-table-changes" {
  for_each       = toset(local.rtb_unauthorised_actions)
  name           = "${var.route_table_changes_metric_filter_name}-${each.key}"
  pattern        = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.route_table_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "route-table-changes" {
  alarm_name        = var.route_table_changes_alarm_name
  alarm_description = "Monitors for AWS EC2 route table changes."
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.route_table_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.14 - Ensure a log metric filter and alarm exist for VPC changes
resource "aws_cloudwatch_log_metric_filter" "vpc-changes" {
  for_each       = toset(local.vpc_unauthorised_actions)
  name           = "${var.vpc_changes_metric_filter_name}-${each.key}"
  pattern        = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.vpc_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "vpc-changes" {
  alarm_name        = var.vpc_changes_alarm_name
  alarm_description = "Monitors for AWS VPC changes."
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.vpc_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# Changes to private link resources
resource "aws_cloudwatch_metric_alarm" "privatelink_new_flow_count_all" {
  alarm_name          = var.privatelink_new_flow_count_all_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = "100" # Adjust this threshold as needed
  alarm_description   = "This alarm monitors the total number of new flows across all VPC endpoints."

  metric_query {
    id          = "e1"
    expression  = "SUM(METRICS())"
    label       = "Total New Flows"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "NewFlowCount"
      namespace   = "AWS/VpcEndpoints"
      period      = 60
      stat        = "Sum"
    }
  }

  alarm_actions = local.low_priority_alarm_action
  tags          = var.tags
}


resource "aws_cloudwatch_metric_alarm" "privatelink_active_flow_count_all" {
  alarm_name          = var.privatelink_active_flow_count_all_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = "1000" # Adjust this threshold as needed
  alarm_description   = "This alarm monitors the total number of active flows across all VPC endpoints."
  alarm_actions       = local.low_priority_alarm_action

  metric_query {
    id          = "e1"
    expression  = "SUM(METRICS())"
    label       = "Total Active Flows"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "ActiveFlowCount"
      namespace   = "AWS/VpcEndpoints"
      period      = 60
      stat        = "Average"
    }
  }

  tags = var.tags
}

# New Connection Count Alarm
resource "aws_cloudwatch_metric_alarm" "privatelink_service_new_connection_count_all" {
  alarm_name          = var.privatelink_service_new_connection_count_all_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = "100" # Adjust this threshold as needed
  alarm_description   = "This alarm monitors the total number of new connections across all VPC Endpoint Services."
  alarm_actions       = local.low_priority_alarm_action

  metric_query {
    id          = "e1"
    expression  = "SUM(METRICS())"
    label       = "Total New Connections"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "NewConnectionCount"
      namespace   = "AWS/PrivateLinkServices"
      period      = 60
      stat        = "Sum"
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "privatelink_service_active_connection_count_all" {
  alarm_name          = var.privatelink_service_active_connection_count_all_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = "1000" # Adjust this threshold as needed
  alarm_description   = "This alarm monitors the total number of active connections across all VPC Endpoint Services."
  alarm_actions = local.low_priority_alarm_action

  metric_query {
    id          = "e1"
    expression  = "SUM(METRICS())"
    label       = "Total Active Connections"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "ActiveConnectionCount"
      namespace   = "AWS/PrivateLinkServices"
      period      = 60
      stat        = "Average"
    }
  }
  tags          = var.tags
}

# Alerts for all change events for transit-gateway resources outside of trusted automation
resource "aws_cloudwatch_log_metric_filter" "transit-gateway-changes" {
  name           = var.transit_gateway_changes_metric_filter_name
  pattern        = "{(($.eventName = \"*TransitGateway*\") && ($.readOnly = \"false\") && ${local.automation_role_filter})}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.transit_gateway_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "transit-gateway-changes" {
  alarm_name        = var.transit_gateway_changes_alarm_name
  alarm_description = "Monitors for AWS EC2 transit gateway changes."
  alarm_actions     = local.low_priority_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.transit_gateway_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# Alerts for VPN changes made outside of trusted automation roles
resource "aws_cloudwatch_log_metric_filter" "vpn-changes" {
  name           = "vpn-changes"
  pattern        = "{((($.eventName = \"CreateVpnConnection\") || ($.eventName = \"DeleteVpnConnection\") || ($.eventName = \"ModifyVpnConnection\") || ($.eventName = \"CreateVpnConnectionRoute\") || ($.eventName = \"DeleteVpnConnectionRoute\") || ($.eventName = \"CreateVpnGateway\") || ($.eventName = \"DeleteVpnGateway\") || ($.eventName = \"AttachVpnGateway\") || ($.eventName = \"DetachVpnGateway\") || ($.eventName = \"CreateCustomerGateway\") || ($.eventName = \"DeleteCustomerGateway\")) && ${local.automation_role_filter})}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "vpn-changes"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "vpn-changes" {
  alarm_name        = "vpn-changes"
  alarm_description = "Monitors for VPN changes."
  alarm_actions     = local.low_priority_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "vpn-changes"
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# Alerts for all change made to network firewalls outside of trusted automation roles
resource "aws_cloudwatch_log_metric_filter" "network_firewall_changes" {
  count          = local.account_name == "core-network-services-production" ? 1 : 0
  name           = "network-firewall-changes"
  pattern        = "{((($.eventName = \"*Firewall*\") || ($.eventName = \"*RuleGroup*\") || ($.eventName = \"*ResourcePolicy\") || ($.eventName = \"*TLSInspectionConfiguration\") || ($.eventName = \"*AvailabilityZones\") || ($.eventName = \"*Subnets\") || ($.eventName = \"TagResource\") || ($.eventName = \"UntagResource\")) && ${local.automation_role_filter})}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "network-firewall-changes"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "network_firewall_changes" {
  count             = local.account_name == "core-network-services-production" ? 1 : 0
  alarm_name        = "network-firewall-changes"
  alarm_description = "Monitors for changes to Network Firewalls in core-network-services outside of automation"
  alarm_actions     = local.low_priority_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "network-firewall-changes"
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}
