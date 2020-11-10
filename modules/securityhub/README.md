# AWS SecurityHub

Terraform module for enabling [AWS SecurityHub](https://aws.amazon.com/security-hub/).

## SecurityHub Standards
This module enables the following SecurityHub standards:
- [x] AWS Foundational Security Best Practices v1.0.0
- [x] CIS AWS Foundations Benchmark v1.2.0
- [x] PCI DSS v3.2.1

## SecurityHub findings remediation
The `modernisation-platform-terraform-baselines` module offers other modules to remediate failed findings:

- [SecurityHub Alarms](../securityhub-alarms) remediates 15 checks
- [IAM Password Policy](../iam) remediates 7 checks

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
