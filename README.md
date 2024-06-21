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

## Inputs

|              Name               |                                Description                                |  Type  | Default | Required |
| :-----------------------------: | :-----------------------------------------------------------------------: | :----: | :-----: | -------- |
|         root_account_id         | The AWS Organisations root account ID that this account should be part of | string |         | yes      |
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

[Standards Link]: https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-report/modernisation-platform-terraform-baselines "Repo standards badge."
[Standards Icon]: https://img.shields.io/endpoint?labelColor=231f20&color=005ea5&style=for-the-badge&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fendpoint%2Fmodernisation-platform&logo=data:image/png;base64,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
[Format Code Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-baselines/format-code.yml?labelColor=231f20&style=for-the-badge&label=Formate%20Code
[Format Code Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-baselines/actions/workflows/format-code.yml
[Scorecards Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-baselines/scorecards.yml?branch=main&labelColor=231f20&style=for-the-badge&label=Scorecards
[Scorecards Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-baselines/actions/workflows/scorecards.yml
[SCA Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-baselines/code-scanning.yml?branch=main&labelColor=231f20&style=for-the-badge&label=Secure%20Code%20Analysis
[SCA Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-baselines/actions/workflows/code-scanning.yml
[Terraform SCA Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-baselines/code-scanning.yml?branch=main&labelColor=231f20&style=for-the-badge&label=Terraform%20Static%20Code%20Analysis
[Terraform SCA Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-baselines/actions/workflows/terraform-static-analysis.yml
