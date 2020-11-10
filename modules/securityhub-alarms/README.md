# SecurityHub Alarms

Terraform module for creating CloudWatch Alarms for SecurityHub that comply with the CIS AWS Foundations Benchmark v1.2.0 rules, which are:

- [x] [1.1 – Avoid the use of the "root" account](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.1-remediation) as a by-product of [CIS 3.3 remediation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.3-remediation)
- [x] [3.1 - Ensure a log metric filter and alarm exist for unauthorized API calls](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.1-remediation)
- [x] [3.2 - Ensure a log metric filter and alarm exist for Management Console sign-in without MFA](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.2-remediation)
- [x] [3.3 - Ensure a log metric filter and alarm exist for usage of "root" account and](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.3-remediation)
- [x] [3.4 - Ensure a log metric filter and alarm exist for IAM policy changes](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.4-remediation)
- [x] [3.5 - Ensure a log metric filter and alarm exist for CloudTrail configuration changes](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.5-remediation)
- [x] [3.6 - Ensure a log metric filter and alarm exist for AWS Management Console authentication failures](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.6-remediation)
- [x] [3.7 - Ensure a log metric filter and alarm exist for disabling or scheduled deletion of customer created CMKs](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.7-remediation)
- [x] [3.8 - Ensure a log metric filter and alarm exist for S3 bucket policy changes](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.8-remediation)
- [x] [3.9 - Ensure a log metric filter and alarm exist for AWS Config configuration changes](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.9-remediation)
- [x] [3.10  - Ensure a log metric filter and alarm exist for security group changes](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.10-remediation)
- [x] [3.11  - Ensure a log metric filter and alarm exist for changes to Network Access Control Lists (NACL)](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.11-remediation)
- [x] [3.12  - Ensure a log metric filter and alarm exist for changes to network gateways](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.12-remediation)
- [x] [3.13  - Ensure a log metric filter and alarm exist for route table changes](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.13-remediation)
- [x] [3.14  - Ensure a log metric filter and alarm exist for VPC changes](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.14-remediation)

## Usage

```
module "securityhub-alarms" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/securityhub-alarms"
}
```

## Inputs
| Name | Description                | Type | Default | Required |
|------|----------------------------|------|---------|----------|
| tags | Tags to apply to resources | map  | {}      | no       |

## Outputs
None.

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
