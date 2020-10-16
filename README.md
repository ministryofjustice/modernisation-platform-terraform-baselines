# modernisation-platform-terraform-baselines

Terraform module for enabling and configuring the [MoJ Security Guidance](https://ministryofjustice.github.io/security-guidance/baseline-aws-accounts/#baseline-for-amazon-web-services-accounts) baseline for AWS accounts, alongside some extra reasonable security, identity and compliance  services.

## Enabled Security Guidance services
- [ ] Security email setting
- [x] GuardDuty
- [x] CloudTrail
- [x] Config and Config [Rules](modules/config/README.md)
- [ ] Tagging
- [ ] Regions
- [ ] Identity and Access Management
- [ ] Encryption
- [ ] World Access
- [x] SecurityHub

## Enabled Security, Identity and Compliance services
- [x] IAM Access Analyzer

## Usage
```
module "baselines" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines"
  providers = {
    aws                = aws
    aws.ap-northeast-1 = aws.ap-northeast-1
    aws.ap-northeast-2 = aws.ap-northeast-2
    aws.ap-south-1     = aws.ap-south-1
    aws.ap-southeast-1 = aws.ap-southeast-1
    aws.ap-southeast-2 = aws.ap-southeast-2
    aws.ca-central-1   = aws.ca-central-1
    aws.eu-central-1   = aws.eu-central-1
    aws.eu-north-1     = aws.eu-north-1
    aws.eu-west-1      = aws.eu-west-1
    aws.eu-west-2      = aws.eu-west-2
    aws.eu-west-3      = aws.eu-west-3
    aws.sa-east-1      = aws.sa-east-1
    aws.us-east-1      = aws.us-east-1
    aws.us-east-2      = aws.us-east-2
    aws.us-west-1      = aws.us-west-1
    aws.us-west-2      = aws.us-west-2
  }
  root_account_id = "123456789"
  tags            = {}
}
```

## Inputs
| Name            | Description                                                           | Type   | Default | Required |
|:---------------:|:---------------------------------------------------------------------:|:------:|:-------:|----------|
| root_account_id | AWS Organisations root account ID that this account should be part of | string |         | yes      |
| tags            | Tags to apply to resources, where applicable                          | map    | {}      | no       |

## Outputs
None

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
