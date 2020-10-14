# modernisation-platform-terraform-baselines

Terraform module for generating files to enable and create baseline rules from the [MoJ Security Guidance](https://ministryofjustice.github.io/security-guidance/baseline-aws-accounts/#baseline-for-amazon-web-services-accounts).

## Enabled services
- [ ] Security email setting
- [x] GuardDuty
- [ ] CloudTrail
- [ ] Config
- [ ] Tagging
- [ ] Regions
- [ ] Identity and Access Management
- [ ] Encryption
- [ ] World Access
- [x] SecurityHub

### Regions
This module fetches the AWS regions that are enabled in the consuming account, and fetches the regions that services are available in, to cross-reference and enable services in each required region.
These are commited to the [regions](regions) folder.

## Usage
```
module "baselines" {
  source                = "github.com/ministryofjustice/modernisation-platform-terraform-baselines"
  baseline_directory    = "./generated"
  baseline_provider_key = "aws"
}
```

Once files have been generated, you will have a set of files including `variables.tf` that can control enabled services, which can be used like so:

```
module "generated" {
  source               = "./generated/aws"
  baseline_tags        = local.tags
  baseline_assume_role = local.assumable_role.arn
}
```

## Inputs for baselines
|          Name         |                             Description                             |   Type  | Default | Required |
|:---------------------:|:-------------------------------------------------------------------:|:-------:|:-------:|----------|
|  baseline_assume_role | Whether or not a role needs to be assumed to manage these resources | boolean |  false  | no       |
|   baseline_directory  |         Directory to put this module's generated files into         |  string |         | yes      |
| baseline_provider_key |        A unique provider key to use for provider definitions        |  string |         | yes      |

## Inputs for generated files
|         Name         |                      Description                      |  Type  | Default | Required |
|:--------------------:|:-----------------------------------------------------:|:------:|:-------:|----------|
| baseline_assume_role |      Role ARN to assume to manage these resources     | string |    ""   | no       |
|     baseline_tags    |          Tags to apply to taggable resources          |   map  |         | yes      |

## Outputs
None

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
