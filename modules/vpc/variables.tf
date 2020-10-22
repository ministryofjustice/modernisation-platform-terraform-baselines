variable "iam_role_arn" {
  type        = string
  description = "Role ARN for VPC Flow Logs"
}

variable "tags" {
  type        = map
  description = "Tags to apply to resources, where applicable"
}
