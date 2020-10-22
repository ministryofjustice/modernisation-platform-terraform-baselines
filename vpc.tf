# VPC Flow Log: configure an IAM role
resource "aws_iam_role" "vpc-flow-log" {
  name               = "AWSVPCFlowLog"
  assume_role_policy = data.aws_iam_policy_document.vpc-flow-log-assume-role-policy.json
  tags               = var.tags
}

# VPC Flow Log: assume role policy
data "aws_iam_policy_document" "vpc-flow-log-assume-role-policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

# VPC Flow Log: publish to CloudWatch
resource "aws_iam_policy" "vpc-flow-log-publish-policy" {
  name   = "AWSVPCFlowLogPublishPolicy"
  policy = data.aws_iam_policy_document.vpc-flow-log-publish-policy.json
}

# Extrapolated from:
# https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-cwl.html
data "aws_iam_policy_document" "vpc-flow-log-publish-policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "vpc-flow-log-publish-policy" {
  role       = aws_iam_role.vpc-flow-log.id
  policy_arn = aws_iam_policy.vpc-flow-log-publish-policy.arn
}

# Enable VPC default configuration and Flow Logs in each region
module "vpc-ap-northeast-1" {
  source = "./modules/vpc"
  providers = {
    aws = aws.ap-northeast-1
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}

module "vpc-ap-northeast-2" {
  source = "./modules/vpc"
  providers = {
    aws = aws.ap-northeast-2
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}

module "vpc-ap-south-1" {
  source = "./modules/vpc"
  providers = {
    aws = aws.ap-south-1
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}

module "vpc-ap-southeast-1" {
  source = "./modules/vpc"
  providers = {
    aws = aws.ap-southeast-1
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}

module "vpc-ap-southeast-2" {
  source = "./modules/vpc"
  providers = {
    aws = aws.ap-southeast-2
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}

module "vpc-ca-central-1" {
  source = "./modules/vpc"
  providers = {
    aws = aws.ca-central-1
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}

module "vpc-eu-central-1" {
  source = "./modules/vpc"
  providers = {
    aws = aws.eu-central-1
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}

module "vpc-eu-north-1" {
  source = "./modules/vpc"
  providers = {
    aws = aws.eu-north-1
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}

module "vpc-eu-west-1" {
  source = "./modules/vpc"
  providers = {
    aws = aws.eu-west-1
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}

module "vpc-eu-west-2" {
  source = "./modules/vpc"
  providers = {
    aws = aws.eu-west-2
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}

module "vpc-eu-west-3" {
  source = "./modules/vpc"
  providers = {
    aws = aws.eu-west-3
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}

module "vpc-sa-east-1" {
  source = "./modules/vpc"
  providers = {
    aws = aws.sa-east-1
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}

module "vpc-us-east-1" {
  source = "./modules/vpc"
  providers = {
    aws = aws.us-east-1
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}

module "vpc-us-east-2" {
  source = "./modules/vpc"
  providers = {
    aws = aws.us-east-2
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}

module "vpc-us-west-1" {
  source = "./modules/vpc"
  providers = {
    aws = aws.us-west-1
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}

module "vpc-us-west-2" {
  source = "./modules/vpc"
  providers = {
    aws = aws.us-west-2
  }
  iam_role_arn = aws_iam_role.vpc-flow-log.arn
  tags         = var.tags
}
