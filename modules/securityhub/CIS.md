# CIS AWS Foundations Benchmark standard

This lists the CIS AWS Foundations Benchmark standard rules by whether they're supported in SecurityHub or not, and whether they're remediated by a resource in this repository or not. Some checks aren't permanently remediable, such as `1.12 - Ensure no root account access key exists`, as someone can create access keys at any point and they'll need to be removed manually.

## Supported in SecurityHub
- [x] [1.1 – Avoid the use of the "root" account](../securityhub-alarms)
- [ ] 1.2 – Ensure multi-factor authentication (MFA) is enabled for all IAM users that have a console password
- [ ] 1.3 – Ensure credentials unused for 90 days or greater are disabled
- [ ] 1.4 – Ensure access keys are rotated every 90 days or less
- [x] [1.5 – Ensure IAM password policy requires at least one uppercase letter](../iam)
- [x] [1.6 – Ensure IAM password policy requires at least one lowercase letter](../iam)
- [x] [1.7 – Ensure IAM password policy requires at least one symbol](../iam)
- [x] [1.8 – Ensure IAM password policy requires at least one number](../iam)
- [x] [1.9 – Ensure IAM password policy requires a minimum length of 14 or greater](../iam)
- [x] [1.10 – Ensure IAM password policy prevents password reuse](../iam)
- [x] [1.11 – Ensure IAM password policy expires passwords within 90 days or less](../iam)
- [ ] 1.12 – Ensure no root account access key exists
- [ ] 1.13 – Ensure MFA is enabled for the "root" account
- [ ] 1.14 – Ensure hardware MFA is enabled for the "root" account
- [ ] 1.16 – Ensure IAM policies are attached only to groups or roles
- [x] [1.20 - Ensure a support role has been created to manage incidents with AWS Support](../support)
- [ ] 1.22 – Ensure IAM policies that allow full "*:*" administrative privileges are not created
- [x] [2.1 – Ensure CloudTrail is enabled in all Regions](../cloudtrail)
- [x] [2.2 – Ensure CloudTrail log file validation is enabled](../cloudtrail)
- [x] [2.3 – Ensure the S3 bucket CloudTrail logs to is not publicly accessible](../cloudtrail)
- [x] [2.4 – Ensure CloudTrail trails are integrated with Amazon CloudWatch Logs](../cloudtrail)
- [x] [2.5 – Ensure AWS Config is enabled](../config)
- [x] [2.6 – Ensure S3 bucket access logging is enabled on the CloudTrail S3 bucket](../cloudtrail)
- [x] [2.7 – Ensure CloudTrail logs are encrypted at rest using AWS KMS CMKs](../cloudtrail)
- [ ] 2.8 – Ensure rotation for customer-created CMKs is enabled
- [x] [2.9 – Ensure VPC flow logging is enabled in all VPCs](../vpc)
- [x] [3.1 – Ensure a log metric filter and alarm exist for unauthorized API calls](../securityhub-alarms)
- [x] [3.2 – Ensure a log metric filter and alarm exist for AWS Management Console sign-in without MFA](../securityhub-alarms)
- [x] [3.3 – Ensure a log metric filter and alarm exist for usage of "root" account](../securityhub-alarms)
- [x] [3.4 – Ensure a log metric filter and alarm exist for IAM policy changes](../securityhub-alarms)
- [x] [3.5 – Ensure a log metric filter and alarm exist for CloudTrail configuration changes](../securityhub-alarms)
- [x] [3.6 – Ensure a log metric filter and alarm exist for AWS Management Console authentication failures](../securityhub-alarms)
- [x] [3.7 – Ensure a log metric filter and alarm exist for disabling or scheduled deletion of customer created CMKs](../securityhub-alarms)
- [x] [3.8 – Ensure a log metric filter and alarm exist for S3 bucket policy changes](../securityhub-alarms)
- [x] [3.9 – Ensure a log metric filter and alarm exist for AWS Config configuration changes](../securityhub-alarms)
- [x] [3.10 – Ensure a log metric filter and alarm exist for security group changes](../securityhub-alarms)
- [x] [3.11 – Ensure a log metric filter and alarm exist for changes to Network Access Control Lists (NACL)](../securityhub-alarms)
- [x] [3.12 – Ensure a log metric filter and alarm exist for changes to network gateways](../securityhub-alarms)
- [x] [3.13 – Ensure a log metric filter and alarm exist for route table changes](../securityhub-alarms)
- [x] [3.14 – Ensure a log metric filter and alarm exist for VPC changes](../securityhub-alarms)
- [ ] 4.1 – Ensure no security groups allow ingress from 0.0.0.0/0 to port 22
- [ ] 4.2 – Ensure no security groups allow ingress from 0.0.0.0/0 to port 3389
- [x] [4.3 – Ensure the default security group of every VPC restricts all traffic](../vpc)

## Not supported in SecurityHub
- [ ] 1.15 – Ensure security questions are registered in the AWS account
- [ ] 1.17 – Maintain current contact details
- [ ] 1.18 – Ensure security contact information is registered
- [ ] 1.19 – Ensure IAM instance roles are used for AWS resource access from instances
- [ ] 1.21 – Do not set up access keys during initial user setup for all IAM users that have a console password
- [ ] 4.4 – Ensure routing tables for VPC peering are "least access"
