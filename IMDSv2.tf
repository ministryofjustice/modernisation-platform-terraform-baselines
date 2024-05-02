resource "aws_ec2_instance_metadata_defaults" "enforce-imdsv2" {
  http_tokens                 = "required"
  http_put_response_hop_limit = 2
}