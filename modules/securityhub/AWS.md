# AWS Foundational Security Best Practices standard

This lists the AWS Foundational Security Best Practices standard rules by whether they're supported in SecurityHub or not, and whether they're remediated by a resource in this repository or not. Some checks aren't permanently remediable, such as `IAM.4 - IAM root user access key should not exist`, as someone can create access keys at any point and they'll need to be removed manually.

## Supported in SecurityHub
- [ ] ACM.1 - Imported ACM certificates should be renewed after a specified time period
- [ ] AutoScaling.1 - Auto Scaling groups associated with a load balancer should use load balancer health checks
- [x] [CloudTrail.1 - CloudTrail should be enabled and configured with at least one multi-Region trail](../cloudtrail)
- [x] [CloudTrail.2 - CloudTrail should have encryption at-rest enabled](../cloudtrail)
- [ ] CodeBuild.1 - CodeBuild GitHub or Bitbucket source repository URLs should use OAuth
- [ ] CodeBuild.2 - CodeBuild project environment variables should not contain clear text credentials
- [x] [Config.1 - AWS Config should be enabled](../config)
- [ ] DMS.1 - Database Migration Service replication instances should not be public
- [ ] EC2.1 - Amazon EBS snapshots should not be public, determined by the ability to be restorable by anyone
- [x] [EC2.2 - The VPC default security group should not allow inbound and outbound traffic](../vpc)
- [ ] EC2.3 - Attached EBS volumes should be encrypted at-rest
- [ ] EC2.4 - Stopped EC2 instances should be removed after a specified time period
- [x] [EC2.6 - VPC flow logging should be enabled in all VPCs](../vpc)
- [x] [EC2.7 - EBS default encryption should be enabled](../ebs)
- [ ] EC2.8 - EC2 instances should use IMDSv2
- [ ] EFS.1 - Amazon EFS should be configured to encrypt file data at-rest using AWS KMS
- [ ] ELBv2.1 - Application Load Balancer should be configured to redirect all HTTP requests to HTTPS
- [ ] EMR.1 - Amazon EMR cluster master nodes should not have public IP addresses
- [ ] ES.1 - Elasticsearch domains should have encryption at-rest enabled
- [x] [GuardDuty.1 - GuardDuty should be enabled](../guardduty)
- [ ] IAM.1 - IAM policies should not allow full "*" administrative privileges
- [ ] IAM.2 - IAM users should not have IAM policies attached
- [ ] IAM.3 - IAM users' access keys should be rotated every 90 days or less
- [ ] IAM.4 - IAM root user access key should not exist
- [ ] IAM.5 - MFA should be enabled for all IAM users that have a console password
- [ ] IAM.6 - Hardware MFA should be enabled for the root user
- [x] [IAM.7 - Password policies for IAM users should have strong configurations](../iam)
- [ ] IAM.8 - Unused IAM user credentials should be removed
- [ ] KMS.1 - IAM customer managed policies should not allow decryption actions on all KMS keys
- [ ] KMS.2 - IAM principals should not have IAM inline policies that allow decryption actions on all KMS keys
- [ ] Lambda.1 - Lambda functions should prohibit public access by other accounts
- [ ] Lambda.2 - Lambda functions should use latest runtimes
- [ ] RDS.1 - RDS snapshots should be private
- [ ] RDS.2 - RDS DB instances should prohibit public access, determined by the PubliclyAccessible configuration
- [ ] RDS.3 - RDS DB instances should have encryption at-rest enabled
- [ ] RDS.4 - RDS cluster snapshots and database snapshots should be encrypted at rest
- [ ] RDS.5 - RDS DB instances should be configured with multiple Availability Zones
- [ ] RDS.6 - Enhanced monitoring should be configured for RDS DB instances and clusters
- [ ] RDS.7 - RDS clusters should have deletion protection enabled
- [ ] RDS.8 - RDS DB instances should have deletion protection enabled
- [ ] S3.1 - S3 Block Public Access setting should be enabled
- [ ] S3.2 - S3 buckets should prohibit public read access
- [ ] S3.3 - S3 buckets should prohibit public write access
- [ ] S3.4 - S3 buckets should have server-side encryption enabled
- [ ] S3.5 - S3 buckets should require requests to use Secure Socket Layer
- [ ] S3.6 - Amazon S3 permissions granted to other AWS accounts in bucket policies should be restricted
- [ ] SageMaker.1 - SageMaker notebook instances should not have direct internet access
- [ ] SecretsManager.1 - Secrets Manager secrets should have automatic rotation enabled
- [ ] SecretsManager.2 - Secrets Manager secrets configured with automatic rotation should rotate successfully
- [ ] SSM.1 - EC2 instances should be managed by AWS Systems Manager
- [ ] SSM.2 - All EC2 instances managed by Systems Manager should be compliant with patching requirements
- [ ] SSM.3 - Instances managed by Systems Manager should have an association compliance status of COMPLIANT

## Not supported in SecurityHub
None.
