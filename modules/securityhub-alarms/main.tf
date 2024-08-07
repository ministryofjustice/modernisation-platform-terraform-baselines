data "aws_caller_identity" "current" {}

data "aws_vpc_endpoint" "privatelink_endpoints" {
  # No filters here means it will fetch all VPC endpoints
}
data "aws_vpc_endpoint_service" "privatelink_services" {
  # it will fetch all VPC Endpoint Services in the account
}

# Data source to fetch NAT Gateways
data "aws_nat_gateways" "all" {}

# AWS CloudWatch doesn't support using the AWS-managed KMS key for publishing things from CloudWatch to SNS
# See: https://aws.amazon.com/premiumsupport/knowledge-center/cloudwatch-receive-sns-for-alarm-trigger/
resource "aws_kms_key" "securityhub-alarms" {
  deletion_window_in_days = 7
  description             = "SecurityHub alarms encryption key"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.securityhub-alarms-kms.json
  tags                    = var.tags
}

resource "aws_kms_alias" "securityhub-alarms" {
  name          = "alias/securityhub-alarms_key"
  target_key_id = aws_kms_key.securityhub-alarms.id
}

# SecurityHub alarms KMS multi-Region
resource "aws_kms_key" "securityhub_alarms_multi_region" {
  deletion_window_in_days = 7
  description             = "SecurityHub alarms encryption key"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.securityhub-alarms-kms.json
  tags                    = var.tags
  multi_region            = true
}

resource "aws_kms_alias" "securityhub_alarms_multi_region" {
  name          = "alias/securityhub-alarms-key-multi-region"
  target_key_id = aws_kms_key.securityhub_alarms_multi_region.id
}

data "aws_iam_policy_document" "securityhub-alarms-kms" {

  #checkov:skip=CKV_AWS_356: "Permissions required by sec-hub"
  #checkov:skip=CKV_AWS_111: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_109: "Ensure IAM policies does not allow permissions management / resource exposure without constraints - This is applied to a specific SNS topic"

  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
  }
}

# SNS topic, required for remediation
resource "aws_sns_topic" "securityhub-alarms" {
  name              = "securityhub-alarms"
  kms_master_key_id = aws_kms_key.securityhub-alarms.arn
  tags              = var.tags
}

# CloudWatch alarms for CIS
# 3.1 - Ensure a log metric filter and alarm exist for unauthorized API calls
resource "aws_cloudwatch_log_metric_filter" "unauthorised-api-calls" {
  name           = "unauthorised-api-calls"
  pattern        = "{($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\" && $.eventName != \"ListDelegatedAdministrators\")}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = "unauthorised-api-calls"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorised-api-calls" {
  alarm_name        = "unauthorised-api-calls"
  alarm_description = "Monitors for unauthorised API calls."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.unauthorised-api-calls.id
  namespace           = "LogMetrics"
  period              = "180"
  statistic           = "Sum"
  threshold           = "10"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.2 - Ensure a log metric filter and alarm exist for Management Console sign-in without MFA
resource "aws_cloudwatch_log_metric_filter" "sign-in-without-mfa" {
  name           = "sign-in-without-mfa"
  pattern        = "{($.eventName=\"ConsoleLogin\") && ($.additionalEventData.MFAUsed !=\"Yes\") && ($.userIdentity.type =\"IAMUser\") && ($.responseElements.ConsoleLogin = \"Success\") }"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = "sign-in-without-mfa"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "sign-in-without-mfa" {
  alarm_name        = "sign-in-without-mfa"
  alarm_description = "Monitors for AWS Console sign-in without MFA."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.sign-in-without-mfa.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.3 - Ensure a log metric filter and alarm exist for usage of "root" account and
# 1.1 – Avoid the use of the "root" account
resource "aws_cloudwatch_log_metric_filter" "root-account-usage" {
  name           = "root-account-usage"
  pattern        = "{$.userIdentity.type=\"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType !=\"AwsServiceEvent\"}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = "root-account-usage"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "root-account-usage" {
  alarm_name        = "root-account-usage"
  alarm_description = "Monitors for root account usage."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.root-account-usage.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.4 - Ensure a log metric filter and alarm exist for IAM policy changes
resource "aws_cloudwatch_log_metric_filter" "iam-policy-changes" {
  name           = "iam-policy-changes"
  pattern        = "{($.eventName=DeleteGroupPolicy) || ($.eventName=DeleteRolePolicy) || ($.eventName=DeleteUserPolicy) || ($.eventName=PutGroupPolicy) || ($.eventName=PutRolePolicy) || ($.eventName=PutUserPolicy) || ($.eventName=CreatePolicy) || ($.eventName=DeletePolicy) || ($.eventName=CreatePolicyVersion) || ($.eventName=DeletePolicyVersion) || ($.eventName=AttachRolePolicy) || ($.eventName=DetachRolePolicy) || ($.eventName=AttachUserPolicy) || ($.eventName=DetachUserPolicy) || ($.eventName=AttachGroupPolicy) || ($.eventName=DetachGroupPolicy)}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = "iam-policy-changes"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "iam-policy-changes" {
  alarm_name        = "iam-policy-changes"
  alarm_description = "Monitors for IAM policy changes."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.iam-policy-changes.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.5 - Ensure a log metric filter and alarm exist for CloudTrail configuration changes
resource "aws_cloudwatch_log_metric_filter" "cloudtrail-configuration-changes" {
  name           = "cloudtrail-configuration-changes"
  pattern        = "{($.eventName=CreateTrail) || ($.eventName=UpdateTrail) || ($.eventName=DeleteTrail) || ($.eventName=StartLogging) || ($.eventName=StopLogging)}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = "cloudtrail-configuration-changes"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudtrail-configuration-changes" {
  alarm_name        = "cloudtrail-configuration-changes"
  alarm_description = "Monitors for CloudTrail configuration changes."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.cloudtrail-configuration-changes.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.6 - Ensure a log metric filter and alarm exist for AWS Management Console authentication failures
resource "aws_cloudwatch_log_metric_filter" "sign-in-failures" {
  name           = "sign-in-failures"
  pattern        = "{($.eventName=ConsoleLogin) && ($.errorMessage=\"Failed authentication\")}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = "sign-in-failures"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "sign-in-failures" {
  alarm_name        = "sign-in-failures"
  alarm_description = "Monitors for AWS Console sign-in failures."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.sign-in-failures.id
  namespace           = "LogMetrics"
  period              = "60"
  statistic           = "Sum"
  threshold           = "5"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.7 - Ensure a log metric filter and alarm exist for disabling or scheduled deletion of customer created CMKs
resource "aws_cloudwatch_log_metric_filter" "cmk-removal" {
  name           = "cmk-removal"
  pattern        = "{($.eventSource=kms.amazonaws.com) && (($.eventName=DisableKey) || ($.eventName=ScheduleKeyDeletion))}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = "cmk-removal"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "cmk-removal" {
  alarm_name        = "cmk-removal"
  alarm_description = "Monitors for AWS KMS customer-created CMK removal (deletion or disabled)."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.cmk-removal.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.8 - Ensure a log metric filter and alarm exist for S3 bucket policy changes
resource "aws_cloudwatch_log_metric_filter" "s3-bucket-policy-changes" {
  name           = "s3-bucket-policy-changes"
  pattern        = "{($.eventSource=s3.amazonaws.com) && (($.eventName=PutBucketAcl) || ($.eventName=PutBucketPolicy) || ($.eventName=PutBucketCors) || ($.eventName=PutBucketLifecycle) || ($.eventName=PutBucketReplication) || ($.eventName=DeleteBucketPolicy) || ($.eventName=DeleteBucketCors) || ($.eventName=DeleteBucketLifecycle) || ($.eventName=DeleteBucketReplication))}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = "s3-bucket-policy-changes"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "s3-bucket-policy-changes" {
  alarm_name        = "s3-bucket-policy-changes"
  alarm_description = "Monitors for AWS S3 bucket policy changes."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.s3-bucket-policy-changes.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.9 - Ensure a log metric filter and alarm exist for AWS Config configuration changes
resource "aws_cloudwatch_log_metric_filter" "config-configuration-changes" {
  name           = "config-configuration-changes"
  pattern        = "{($.eventSource=config.amazonaws.com) && (($.eventName=StopConfigurationRecorder) || ($.eventName=DeleteDeliveryChannel) || ($.eventName=PutDeliveryChannel) || ($.eventName=PutConfigurationRecorder))}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = "config-configuration-changes"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "config-configuration-changes" {
  alarm_name        = "config-configuration-changes"
  alarm_description = "Monitors for AWS Config configuration changes."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.config-configuration-changes.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.10 - Ensure a log metric filter and alarm exist for security group changes
resource "aws_cloudwatch_log_metric_filter" "security-group-changes" {
  name           = "security-group-changes"
  pattern        = "{($.eventName=AuthorizeSecurityGroupIngress) || ($.eventName=AuthorizeSecurityGroupEgress) || ($.eventName=RevokeSecurityGroupIngress) || ($.eventName=RevokeSecurityGroupEgress) || ($.eventName=CreateSecurityGroup) || ($.eventName=DeleteSecurityGroup)}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = "security-group-changes"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "security-group-changes" {
  alarm_name        = "security-group-changes"
  alarm_description = "Monitors for AWS EC2 Security Group changes."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.security-group-changes.id
  namespace           = "LogMetrics"
  period              = "180"
  statistic           = "Sum"
  threshold           = "9"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.11 - Ensure a log metric filter and alarm exist for changes to Network Access Control Lists (NACL)
resource "aws_cloudwatch_log_metric_filter" "nacl-changes" {
  name           = "nacl-changes"
  pattern        = "{($.eventName=CreateNetworkAcl) || ($.eventName=CreateNetworkAclEntry) || ($.eventName=DeleteNetworkAcl) || ($.eventName=DeleteNetworkAclEntry) || ($.eventName=ReplaceNetworkAclEntry) || ($.eventName=ReplaceNetworkAclAssociation)}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = "nacl-changes"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "nacl-changes" {
  alarm_name        = "nacl-changes"
  alarm_description = "Monitors for AWS EC2 Network Access Control Lists changes."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.nacl-changes.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.12 - Ensure a log metric filter and alarm exist for changes to network gateways
resource "aws_cloudwatch_log_metric_filter" "network-gateway-changes" {
  name           = "network-gateway-changes"
  pattern        = "{($.eventName=CreateCustomerGateway) || ($.eventName=DeleteCustomerGateway) || ($.eventName=AttachInternetGateway) || ($.eventName=CreateInternetGateway) || ($.eventName=DeleteInternetGateway) || ($.eventName=DetachInternetGateway)}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = "network-gateway-changes"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "network-gateway-changes" {
  alarm_name        = "network-gateway-changes"
  alarm_description = "Monitors for AWS EC2 network gateway changes."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.network-gateway-changes.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.13 - Ensure a log metric filter and alarm exist for route table changes
resource "aws_cloudwatch_log_metric_filter" "route-table-changes" {
  name           = "route-table-changes"
  pattern        = "{($.eventName=CreateRoute) || ($.eventName=CreateRouteTable) || ($.eventName=ReplaceRoute) || ($.eventName=ReplaceRouteTableAssociation) || ($.eventName=DeleteRouteTable) || ($.eventName=DeleteRoute) || ($.eventName=DisassociateRouteTable)}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = "route-table-changes"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "route-table-changes" {
  alarm_name        = "route-table-changes"
  alarm_description = "Monitors for AWS EC2 route table changes."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.route-table-changes.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.14 - Ensure a log metric filter and alarm exist for VPC changes
resource "aws_cloudwatch_log_metric_filter" "vpc-changes" {
  name           = "vpc-changes"
  pattern        = "{($.eventName=CreateVpc) || ($.eventName=DeleteVpc) || ($.eventName=ModifyVpcAttribute) || ($.eventName=AcceptVpcPeeringConnection) || ($.eventName=CreateVpcPeeringConnection) || ($.eventName=DeleteVpcPeeringConnection) || ($.eventName=RejectVpcPeeringConnection) || ($.eventName=AttachClassicLinkVpc) || ($.eventName=DetachClassicLinkVpc) || ($.eventName=DisableVpcClassicLink) || ($.eventName=EnableVpcClassicLink)}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = "vpc-changes"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "vpc-changes" {
  alarm_name        = "vpc-changes"
  alarm_description = "Monitors for AWS VPC changes."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.vpc-changes.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "NATGatewayErrorPortAllocation" {
  name           = "ErrorPortAllocation"
  pattern        = "{ $.eventSource = \"ec2.amazonaws.com\" && $.eventName = \"CreateNatGateway\" && $.errorCode = \"*\" && $.errorMessage = \"*Port Allocation*\" }"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = "ErrorPortAllocation"
    namespace = "NAT/Gateway"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "ErrorPortAllocation" {
  alarm_name        = "NAT-Gateway-ErrorPortAllocation"
  alarm_description = "This alarm detects when the NAT Gateway is unable to allocate ports to new connections."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ErrorPortAllocation"
  namespace           = "NAT/Gateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}


# NAT PacketsDropCount alarm
resource "aws_cloudwatch_metric_alarm" "nat_packets_drop_count" {
  count               = length(data.aws_nat_gateways.all.ids)
  alarm_name          = "NAT-PacketsDropCount-${data.aws_nat_gateways.all.ids[count.index]}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "PacketsDropCount"
  namespace           = "AWS/NATGateway"
  period              = 60
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "NAT Gateway is dropping packets. This might indicate an issue with the NAT Gateway."

  dimensions = {
    NatGatewayId = data.aws_nat_gateways.all.ids[count.index]
  }

  alarm_actions = [aws_sns_topic.securityhub-alarms.arn]
  tags          = var.tags
}


resource "aws_cloudwatch_metric_alarm" "privatelink_new_flow_count" {
  count               = length(data.aws_vpc_endpoint.privatelink_endpoints.ids)
  alarm_name          = "PrivateLink-NewFlowCount-${data.aws_vpc_endpoint.privatelink_endpoints.ids[count.index]}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "NewFlowCount"
  namespace           = "AWS/VpcEndpoints"
  period              = 60
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This alarm monitors the number of new flows or connections established through the VPC endpoint. A sudden increase in new flows might indicate a potential security issue or unexpected traffic pattern."

  dimensions = {
    EndpointId = data.aws_vpc_endpoint.privatelink_endpoints.ids[count.index]
  }

  alarm_actions = [aws_sns_topic.securityhub-alarms.arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "privatelink_active_flow_count" {
  count               = length(data.aws_vpc_endpoints.privatelink_endpoints.ids)
  alarm_name          = "PrivateLink-ActiveFlowCount-${data.aws_vpc_endpoints.privatelink_endpoints.ids[count.index]}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "ActiveFlowCount"
  namespace           = "AWS/VpcEndpoints"
  period              = 60
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This alarm monitors the number of concurrent active flows or connections through the VPC endpoint. A high number of active flows might indicate high resource utilization or potential performance issues."

  dimensions = {
    EndpointId = data.aws_vpc_endpoint.privatelink_endpoints.ids[count.index]
  }

  alarm_actions = [aws_sns_topic.securityhub-alarms.arn]

  tags = var.tags
}

# New Connection Count Alarm
resource "aws_cloudwatch_metric_alarm" "privatelink_new_connection_count" {
  count               = length(data.aws_vpc_endpoint_service.privatelink_services.service_names)
  alarm_name          = "PrivateLink-NewConnectionCount-${data.aws_vpc_endpoint_service.privatelink_services.service_names[count.index]}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "NewConnectionCount"
  namespace           = "AWS/PrivateLinkServices"
  period              = 60
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This alarm monitors the number of new connections established to the VPC Endpoint Service. A sudden increase might indicate unusual activity."

  dimensions = {
    ServiceName = data.aws_vpc_endpoint_service.privatelink_services.service_name[count.index]
  }

  alarm_actions = [aws_sns_topic.securityhub-alarms.arn]

  tags = var.tags
}

# Active Connection Count Alarm
resource "aws_cloudwatch_metric_alarm" "privatelink_active_connection_count" {
  count               = length(data.aws_vpc_endpoint_service.privatelink_services.service_names)
  alarm_name          = "PrivateLink-ActiveConnectionCount-${data.aws_vpc_endpoint_service.privatelink_services.service_names[count.index]}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "ActiveConnectionCount"
  namespace           = "AWS/PrivateLinkServices"
  period              = 60
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This alarm monitors the number of active connections to the VPC Endpoint Service. A high number might indicate high resource utilization."

  dimensions = {
    ServiceName = data.aws_vpc_endpoint_service.privatelink_services.service_name[count.index]
  }

  alarm_actions = [aws_sns_topic.securityhub-alarms.arn]

  tags = var.tags
}