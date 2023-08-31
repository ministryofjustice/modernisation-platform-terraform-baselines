# AWS SecurityHub

Terraform module for enabling [AWS SecurityHub](https://aws.amazon.com/security-hub/) standards.  The enabling of Security Hub is done at the Organizations level.

## SecurityHub Standards and remediation
This module enables or brings in to Terraform the following SecurityHub standards, and this repository holds other modules to remediate some failed findings:
- [x] [AWS Foundational Security Best Practices v1.0.0](AWS.md)
- [x] [CIS AWS Foundations Benchmark v1.2.0](CIS.md)
- [x] [PCI DSS v3.2.1](PCI.md)

## Usage

```
module "securityhub" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/securityhub"
}
```

## Inputs
None.

## Outputs
None.

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
