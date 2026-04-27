# Fetch the environment definition from the modernisation-platform repo.
# count = 0 for the default (MP) workspace, which has no environments JSON.
data "http" "environment_definition" {
  count = terraform.workspace == "default" ? 0 : 1
  url   = "https://raw.githubusercontent.com/ministryofjustice/modernisation-platform/main/environments/${local.account_name}.json"
}

data "aws_caller_identity" "current" {}

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

locals {
  mp_owned_workspaces = [
    "cooker-development",
    "example-development",
    "long-term-storage-production",
    "sprinkler-development",
    "testing-test",
    "^core-.*"
  ]

  is_mp_workspace = length(regexall(join("|", local.mp_owned_workspaces), terraform.workspace)) > 0

  # Derive the application name by stripping the trailing -<environment> suffix.
  account_name = terraform.workspace == "default" ? "" : replace(terraform.workspace, regex("-[^-]*$", terraform.workspace), "")

  # Decode the environments JSON. Falls back to empty map if unavailable.
  environment_definition = terraform.workspace == "default" ? null : try(
    jsondecode(data.http.environment_definition[0].response_body),
    null
  )

  # True when the account-type in the environments JSON is "member-unrestricted".
  member_unrestricted_account_prefixes = ["bichard7"]
  is_member_unrestricted = (
    try(local.environment_definition["account-type"], "") == "member-unrestricted" ||
    anytrue([for p in local.member_unrestricted_account_prefixes : startswith(terraform.workspace, "${p}-")])
  )

  # Extract the environment suffix (last segment after the final dash, e.g. "development")
  environment_name = terraform.workspace == "default" ? "" : regex("[^-]+$", terraform.workspace)

  # Find the access list for the current environment in the JSON
  current_environment_access = try(
    [for env in local.environment_definition["environments"] : env["access"]
      if env["name"] == local.environment_name
    ][0],
    []
  )

  # True when any access entry for this environment has level = "sandbox"
  is_sandbox_environment = length([
    for a in local.current_environment_access : a
    if try(a["level"], "") == "sandbox"
  ]) > 0

  # Combined suppression flag
  is_suppressed_account = local.is_member_unrestricted || local.is_sandbox_environment

  # Alarm actions

  # Low priority alarms action
  low_priority_alarm_action = [aws_sns_topic.securityhub-alarms.arn]

  # Low priority alarms enabled for MP-owned workspaces only
  mp_accounts_low_priority_alarm_action = local.is_mp_workspace ? local.low_priority_alarm_action : []

  # High-priority alarms disabled for suppressed accounts (member-unrestricted or sandbox), enabled everywhere else.
  high_priority_excluding_suppressed_alarm_action = local.is_suppressed_account ? [] : [aws_sns_topic.high_priority_alarms_topic.arn]

  # High-priority alarms disabled for alerts from member-unrestricted account only, enabled everywhere else.
  high_priority_excluding_member_unrestricted_action = local.is_member_unrestricted ? [] : [aws_sns_topic.high_priority_alarms_topic.arn]

  # Low priority alarms disabled for suppressed accounts (member-unrestricted or sandbox), enabled everywhere else.
  low_priority_excluding_suppressed_alarm_action = local.is_suppressed_account ? [] : local.low_priority_alarm_action

  # Excludes known automation roles from triggering alarms, varying by account type:
  #   MP account (default workspace): uses github-actions OIDC role directly (no assume_role in provider)
  #   Core accounts (core-*):         uses ModernisationPlatformAccess only
  #   CP accounts (cloud-platform-*): uses ModernisationPlatformAccess, MemberInfrastructureAccess, and github-actions-development-cluster
  #   Member accounts (all others):   uses ModernisationPlatformAccess or MemberInfrastructureAccess
  is_mp_account   = terraform.workspace == "default"
  is_core_account = length(regexall("^core-", terraform.workspace)) > 0
  is_cp_account   = length(regexall("^cloud-platform-", terraform.workspace)) > 0

  automation_role_filter = (
    local.is_mp_account ? (
      "(($.userIdentity.type != \"AssumedRole\") || (($.userIdentity.sessionContext.sessionIssuer.userName != \"github-actions\") && ($.userIdentity.sessionContext.sessionIssuer.userName != \"github-actions-apply\")))"
      ) : local.is_core_account ? (
      "(($.userIdentity.type != \"AssumedRole\") || ($.userIdentity.sessionContext.sessionIssuer.userName != \"ModernisationPlatformAccess\"))"
      ) : local.is_cp_account ? (
      "(($.userIdentity.type != \"AssumedRole\") || (($.userIdentity.sessionContext.sessionIssuer.userName != \"ModernisationPlatformAccess\") && ($.userIdentity.sessionContext.sessionIssuer.userName != \"MemberInfrastructureAccess\") && ($.userIdentity.sessionContext.sessionIssuer.userName != \"github-actions-development-cluster\")))"
      ) : (
      "(($.userIdentity.type != \"AssumedRole\") || (($.userIdentity.sessionContext.sessionIssuer.userName != \"ModernisationPlatformAccess\") && ($.userIdentity.sessionContext.sessionIssuer.userName != \"MemberInfrastructureAccess\")))"
    )
  )
  
  iam_policy_change_event_names = [
    "DeleteGroupPolicy",
    "DeleteRolePolicy",
    "DeleteUserPolicy",
    "PutGroupPolicy",
    "PutRolePolicy",
    "PutUserPolicy",
    "CreatePolicy",
    "DeletePolicy",
    "CreatePolicyVersion",
    "DeletePolicyVersion",
    "AttachRolePolicy",
    "DetachRolePolicy",
    "AttachUserPolicy",
    "DetachUserPolicy",
    "AttachGroupPolicy",
    "DetachGroupPolicy",
  ]

  cloudtrail_configuration_change_event_names = [
    "CreateTrail",
    "UpdateTrail",
    "DeleteTrail",
    "StartLogging",
    "StopLogging",
  ]

  s3_bucket_policy_change_event_names = [
    "PutBucketAcl",
    "PutBucketPolicy",
    "PutBucketCors",
    "PutBucketLifecycle",
    "PutBucketReplication",
    "DeleteBucketPolicy",
    "DeleteBucketCors",
    "DeleteBucketLifecycle",
    "DeleteBucketReplication",
  ]

  config_configuration_change_event_names = [
    "StopConfigurationRecorder",
    "DeleteDeliveryChannel",
    "PutDeliveryChannel",
    "PutConfigurationRecorder",
  ]

  security_group_change_event_names = [
    "AuthorizeSecurityGroupIngress",
    "AuthorizeSecurityGroupEgress",
    "RevokeSecurityGroupIngress",
    "RevokeSecurityGroupEgress",
    "CreateSecurityGroup",
    "DeleteSecurityGroup",
  ]

  nacl_unauthorised_event_names = [
    "CreateNetworkAcl",
    "CreateNetworkAclEntry",
    "DeleteNetworkAcl",
    "DeleteNetworkAclEntry",
    "ReplaceNetworkAclEntry",
    "ReplaceNetworkAclAssociation"
  ]

  ngw_unauthorised_event_names = [
    "CreateCustomerGateway",
    "DeleteCustomerGateway",
    "AttachInternetGateway",
    "CreateInternetGateway",
    "DeleteInternetGateway",
    "DetachInternetGateway"
  ]

  rtb_unauthorised_actions = [
    "CreateRoute",
    "CreateRouteTable",
    "ReplaceRoute",
    "ReplaceRouteTableAssociation",
    "DeleteRouteTable",
    "DeleteRoute",
    "DisassociateRouteTable"
  ]

  vpc_unauthorised_actions = [
    "CreateVpc",
    "DeleteVpc",
    "ModifyVpcAttribute",
    "AcceptVpcPeeringConnection",
    "CreateVpcPeeringConnection",
    "DeleteVpcPeeringConnection",
    "RejectVpcPeeringConnection",
    "AttachClassicLinkVpc",
    "DetachClassicLinkVpc",
    "DisableVpcClassicLink",
    "EnableVpcClassicLink"
  ]
}


