import json
import os
import logging
import boto3

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients (using environment variables for region)
ssm = boto3.client('ssm', region_name=os.getenv('REGION', 'eu-west-2'))
ecs = boto3.client('ecs', region_name=os.getenv('REGION', 'eu-west-2'))
eks = boto3.client('eks', region_name=os.getenv('REGION', 'eu-west-2'))
ec2 = boto3.client('ec2', region_name=os.getenv('REGION', 'eu-west-2'))
sns = boto3.client('sns', region_name=os.getenv('REGION', 'eu-west-2'))

# Function to retrieve the latest AMI IDs for ECS and EKS from SSM
def get_latest_ami_ids():
    try:
        # Fetch the latest ECS AMI from SSM
        ecs_ami_param = '/aws/service/ecs/optimized-ami/amazon-linux-2/recommended'
        ecs_ami_response = ssm.get_parameter(Name=ecs_ami_param)
        latest_ecs_ami = json.loads(ecs_ami_response['Parameter']['Value'])['image_id']
        logger.info(f"Latest ECS AMI: {latest_ecs_ami}")

        # Fetch the latest EKS AMI by dynamically determining the cluster version
        eks_ami_param_base = '/aws/service/eks/optimized-ami/{version}/amazon-linux-2/recommended/image_id'

        eks_version = eks.describe_cluster(name='your-cluster-name')['cluster']['version']
        eks_ami_param = eks_ami_param_base.format(version=eks_version)

        eks_ami_response = ssm.get_parameter(Name=eks_ami_param)
        latest_eks_ami = eks_ami_response['Parameter']['Value']
        logger.info(f"Latest EKS AMI: {latest_eks_ami}")

    except Exception as e:
        logger.error(f"Error fetching AMI IDs: {str(e)}")
        raise

    return latest_ecs_ami, latest_eks_ami

# Function to check ECS instances for outdated AMIs
def check_ecs_instances(latest_ecs_ami):
    outdated_instances = []
    try:
        # List ECS clusters
        clusters = ecs.list_clusters()['clusterArns']
        for cluster in clusters:
            # List container instances in the ECS cluster
            container_instances = ecs.list_container_instances(cluster=cluster)['containerInstanceArns']

            if container_instances:
                # Describe container instances
                described_instances = ecs.describe_container_instances(
                    cluster=cluster,
                    containerInstances=container_instances
                )['containerInstances']

                for instance in described_instances:
                    ec2_instance_id = instance['ec2InstanceId']

                    # Get the current AMI ID of the EC2 instance
                    ec2_instance = ec2.describe_instances(InstanceIds=[ec2_instance_id])
                    current_ami_id = ec2_instance['Reservations'][0]['Instances'][0]['ImageId']

                    # Compare AMIs
                    if current_ami_id != latest_ecs_ami:
                        outdated_instances.append(f"ECS instance {ec2_instance_id} is using outdated AMI: {current_ami_id}")

    except Exception as e:
        logger.error(f"Error checking ECS instances: {str(e)}")
        raise

    return outdated_instances

# Function to check EKS instances for outdated AMIs
def check_eks_instances(latest_eks_ami):
    outdated_instances = []
    try:
        # List EKS clusters
        clusters = eks.list_clusters()['clusters']
        for cluster in clusters:
            # List node groups for each EKS cluster
            node_groups = eks.list_nodegroups(clusterName=cluster)['nodegroups']
            for node_group in node_groups:
                # Get EC2 instances associated with this node group by filtering with tag
                ec2_instances = ec2.describe_instances(
                    Filters=[
                        {'Name': 'tag:eks:nodegroup-name', 'Values': [node_group]},
                        {'Name': 'instance-state-name', 'Values': ['running']}
                    ]
                )['Reservations']

                for reservation in ec2_instances:
                    for instance in reservation['Instances']:
                        ec2_instance_id = instance['InstanceId']
                        current_ami_id = instance['ImageId']

                        # Compare AMIs
                        if current_ami_id != latest_eks_ami:
                            outdated_instances.append(f"EKS instance {ec2_instance_id} is using outdated AMI: {current_ami_id}")

    except Exception as e:
        logger.error(f"Error checking EKS instances: {str(e)}")
        raise

    return outdated_instances

# Function to send an SNS notification
def send_sns_notification(outdated_instances):
    sns_topic_arn = os.getenv('SNS_TOPIC_ARN')

    if not sns_topic_arn:
        logger.error("SNS_TOPIC_ARN is not set.")
        return

    try:
        message = '\n'.join(outdated_instances)
        sns.publish(
            TopicArn=sns_topic_arn,
            Message=message,
            Subject="Outdated ECS/EKS AMI Notification"
        )
    except Exception as e:
        logger.error(f"Error sending SNS notification: {str(e)}")

# Main function to check ECS and EKS instances and send notifications
def main():
    logger.info("Starting AMI check for ECS and EKS instances")

    # Fetch the latest recommended AMIs for ECS and EKS
    latest_ecs_ami, latest_eks_ami = get_latest_ami_ids()

    # Check ECS instances
    outdated_ecs_instances = check_ecs_instances(latest_ecs_ami)

    # Check EKS instances
    outdated_eks_instances = check_eks_instances(latest_eks_ami)

    # Combine the results
    outdated_instances = outdated_ecs_instances + outdated_eks_instances

    if outdated_instances:
        logger.info("Outdated AMIs detected, sending notification...")
        send_sns_notification(outdated_instances)
    else:
        logger.info("No outdated AMIs detected.")

    logger.info("AMI check complete")

# Lambda handler function
def lambda_handler(event, context):
    main()
