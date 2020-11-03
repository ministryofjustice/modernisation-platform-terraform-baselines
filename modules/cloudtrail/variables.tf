variable "replication_role_arn" {
  type        = string
  description = "Role ARN for S3 replication"
}

variable "tags" {
  type        = map
  description = "Tags to apply to resources, where applicable"
}
