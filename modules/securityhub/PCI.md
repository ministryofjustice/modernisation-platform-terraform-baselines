# PCI DSS standard

This lists the PCI DSS standard rules by whether they're supported in SecurityHub or not, and whether they're remediated by a resource in this repository or not. Some checks aren't permanently remediable, such as `1.12 - Ensure no root account access key exists`, as someone can create access keys at any point and they'll need to be removed manually.

## Supported in SecurityHub
- [ ] PCI.AutoScaling.1 - Auto Scaling groups associated with a load balancer should use health checks
- [x] [PCI.CloudTrail.1 - CloudTrail logs should be encrypted at rest using AWS KMS CMKs](../cloudtrail)
- [x] [PCI.CloudTrail.2 - CloudTrail should be enabled](../cloudtrail)
- [x] [PCI.CloudTrail.3 - CloudTrail log file validation should be enabled](../cloudtrail)
- [x] [PCI.CloudTrail.4 - CloudTrail trails should be integrated with CloudWatch Logs](../cloudtrail)
- [ ] PCI.CodeBuild.1 - CodeBuild GitHub or Bitbucket source repository URLs should use OAuth
- [ ] PCI.CodeBuild.2 - CodeBuild project environment variables should not contain clear text credentials
- [x] [PCI.Config.1 - AWS Config should be enabled](../config)
- [x] [PCI.CW.1 - A log metric filter and alarm should exist for usage of the "root" user](../securityhub-alarms)
- [ ] PCI.DMS.1 - AWS Database Migration Service replication instances should not be public
- [ ] PCI.EC2.1 - Amazon EBS snapshots should not be publicly restorable
- [x] [PCI.EC2.2 - VPC default security group should prohibit inbound and outbound traffic](../vpc)
- [ ] PCI.EC2.3 - Unused EC2 security groups should be removed
- [ ] PCI.EC2.4 - Unused EC2 EIPs should be removed
- [ ] PCI.EC2.5 - Security groups should not allow ingress from 0.0.0.0/0 to port 22
- [x] [PCI.EC2.6 - VPC flow logging should be enabled in all VPCs](../vpc)
- [ ] PCI.ELBV2.1 - Application Load Balancer should be configured to redirect all HTTP requests to HTTPS
- [ ] PCI.ES.1 - Amazon Elasticsearch Service domains should be in a VPC
- [ ] PCI.ES.2 - Amazon Elasticsearch Service domains should have encryption at rest enabled
- [x] [PCI.GuardDuty.1 - GuardDuty should be enabled](../guardduty)
- [ ] PCI.IAM.1 - IAM root user access key should not exist
- [ ] PCI.IAM.2 - IAM users should not have IAM policies attached
- [ ] PCI.IAM.3 - IAM policies should not allow full "*" administrative privileges
- [ ] PCI.IAM.4 - Hardware MFA should be enabled for the root user
- [ ] PCI.IAM.5 - Virtual MFA should be enabled for the root user
- [ ] PCI.IAM.6 - MFA should be enabled for all IAM users
- [ ] PCI.IAM.7 - IAM user credentials should be disabled if not used within a predefined number of days
- [x] [PCI.IAM.8 - Password policies for IAM users should have strong configurations](../iam)
- [ ] PCI.KMS.1 - Customer master key (CMK) rotation should be enabled
- [ ] PCI.Lambda.1 - Lambda functions should prohibit public access
- [ ] PCI.Lambda.2 - Lambda functions should be in a VPC
- [ ] PCI.RDS.1 - RDS snapshots should prohibit public access
- [ ] PCI.RDS.2 - RDS DB Instances should prohibit public access
- [ ] PCI.Redshift.1 - Amazon Redshift clusters should prohibit public access
- [ ] PCI.S3.1 - S3 buckets should prohibit public write access
- [ ] PCI.S3.2 - S3 buckets should prohibit public read access
- [ ] PCI.S3.3 - S3 buckets should have cross-region replication enabled
- [ ] PCI.S3.4 - S3 buckets should have server-side encryption enabled
- [ ] PCI.S3.5 - S3 buckets should require requests to use Secure Socket Layer
- [ ] PCI.S3.6 - S3 Block Public Access setting should be enabled
- [ ] PCI.SageMaker.1 - Amazon SageMaker notebook instances should not have direct internet access
- [ ] PCI.SSM.1 - Amazon EC2 instances managed by Systems Manager should have a patch compliance status of COMPLIANT after a patch installation
- [ ] PCI.SSM.2 - Instances managed by Systems Manager should have an association compliance status of COMPLIANT
- [ ] PCI.SSM.3 - EC2 instances should be managed by AWS Systems Manager

## Not supported in SecurityHub
None.
