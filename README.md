# Modernisation Platform Terraform Baselines Module

[![Standards Icon]][Standards Link] [![Format Code Icon]][Format Code Link] [![Scorecards Icon]][Scorecards Link]

[![SCA Icon]][SCA Link] [![Terraform SCA Icon]][Terraform SCA Link]

Terraform module for enabling and configuring the [MoJ Security Guidance](https://ministryofjustice.github.io/security-guidance/baseline-aws-accounts/#baseline-for-amazon-web-services-accounts) baseline for AWS accounts, alongside some extra reasonable security, identity and compliance services.

## Enabled MoJ Security Guidance configurations

- [ ] Security email setting
- [x] [GuardDuty](modules/guardduty/README.md)
- [x] [CloudTrail](modules/cloudtrail/README.md)
- [x] [Config](modules/config/README.md) and Config [rules](modules/config/RULES.md)
- [ ] Tagging
- [ ] Regions
- [ ] Identity and Access Management
- [ ] Encryption
- [ ] World Access
- [x] [SecurityHub](modules/securityhub/README.md)

## Other enabled configurations

- [x] [AWS Backup](modules/backup/README.md)
- [x] [AWS IAM Access Analyzer](modules/access-analyzer/README.md)
- [x] [AWS IAM password policy](modules/iam/README.md)
- [x] [AWS IAM role for Support](modules/support/README.md)
- [x] [EBS encryption](modules/ebs/README.md)
- [x] [SecurityHub alarms](modules/securityhub-alarms/README.md)
- [x] [VPC logging for default VPCs](modules/vpc/README.md)
- [x] [IMDSv2 by default](modules/imdsv2/README.md)
- [x] [Systems Manager - block public sharing](modules/ssm/README.md)

## Usage

### Using the whole module

```
module "baselines" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines"
  providers = {
    aws                    = aws
    aws.replication-region = aws.eu-west-2 # Region to replicate S3 buckets into
    aws.ap-northeast-1     = aws.ap-northeast-1
    aws.ap-northeast-2     = aws.ap-northeast-2
    aws.ap-south-1         = aws.ap-south-1
    aws.ap-southeast-1     = aws.ap-southeast-1
    aws.ap-southeast-2     = aws.ap-southeast-2
    aws.ca-central-1       = aws.ca-central-1
    aws.eu-central-1       = aws.eu-central-1
    aws.eu-north-1         = aws.eu-north-1
    aws.eu-west-1          = aws.eu-west-1
    aws.eu-west-2          = aws.eu-west-2
    aws.eu-west-3          = aws.eu-west-3
    aws.sa-east-1          = aws.sa-east-1
    aws.us-east-1          = aws.us-east-1
    aws.us-east-2          = aws.us-east-2
    aws.us-west-1          = aws.us-west-1
    aws.us-west-2          = aws.us-west-2
  }

  # Enable IAM Access Analyzer in eu-west-2
  enabled_access_analyzer_regions = ["eu-west-2"]

  root_account_id    = "123456789"
  tags               = {}
}
```

### Using parts of the module

You can specify submodules from this directory to use individually, by [setting the source with a double-slash](https://www.terraform.io/docs/modules/sources.html#modules-in-package-sub-directories) (`//`). Note that this only uses the module in the calling region, unless you specify different module blocks with other Terraform providers. Each module has its own README.

```
module "ebs-encryption" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/ebs"
}
```

### Security Hub forwarding

Set `enable_securityhub_event_forwarding = true`, `securityhub_central_event_bus_arn` to your shared bus, and (optionally) tailor `securityhub_forwarding_scope` to control which severity labels are forwarded. Because forwarding no longer depends on Slack alerts, you can keep Slack disabled while still sending findings to the central bus.

## Inputs

|              Name               |                                Description                                |  Type  | Default | Required |
| :-----------------------------: | :-----------------------------------------------------------------------: | :----: | :-----: | -------- |
|         root_account_id         | The AWS Organisations root account ID that this account should be part of | string |         | yes      |
|         current_acount_id       | The ID for the account into which the module is being deployed            | string |         | yes
|              tags               |               Tags to apply to resources, where applicable                |  map   |   {}    | no       |
| enabled_access_analyzer_regions |                 Regions to enable IAM Access Analyzer in                  |  list  |   []    | no       |
|     enabled_backup_regions      |                      Regions to enable AWS Backup in                      |  list  |   []    | no       |
|     enabled_config_regions      |                      Regions to enable AWS Config in                      |  list  |   []    | no       |
| enabled_ebs_encryption_regions  |                    Regions to enable EBS encryption in                    |  list  |   []    | no       |
|    enabled_guardduty_regions    |                      Regions to enable GuardDuty in                       |  list  |   []    | no       |
|   enabled_securityhub_regions   |                     Regions to enable SecurityHub in                      |  list  |   []    | no       |
|       enabled_vpc_regions       |     Regions to enable default VPC configuration and VPC Flow Logs in      |  list  |   []    | no       |

## Outputs

None

## Looking for issues?

If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

[Standards Link]: https://github-community.service.justice.gov.uk/repository-standards/modernisation-platform-terraform-baselines "Repo standards badge."
[Standards Icon]: https://github-community.service.justice.gov.uk/repository-standards/api/modernisation-platform-terraform-baselines/badge
[Format Code Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-baselines/format-code.yml?labelColor=231f20&style=for-the-badge&label=Formate%20Code
[Format Code Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-baselines/actions/workflows/format-code.yml
[Scorecards Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-baselines/scorecards.yml?branch=main&labelColor=231f20&style=for-the-badge&label=Scorecards
[Scorecards Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-baselines/actions/workflows/scorecards.yml
[SCA Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-baselines/code-scanning.yml?branch=main&labelColor=231f20&style=for-the-badge&label=Secure%20Code%20Analysis
[SCA Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-baselines/actions/workflows/code-scanning.yml
[Terraform SCA Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-baselines/code-scanning.yml?branch=main&labelColor=231f20&style=for-the-badge&label=Terraform%20Static%20Code%20Analysis
[Terraform SCA Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-baselines/actions/workflows/terraform-static-analysis.yml
