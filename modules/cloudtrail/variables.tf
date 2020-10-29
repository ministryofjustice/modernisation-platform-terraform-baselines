variable "replication_region" {
  type        = string
  description = "Region to replicate S3 buckets into"
}

variable "replication_role_arn" {
  type        = string
  description = "Role ARN for S3 replication"
}

variable "tags" {
  type        = map
  description = "Tags to apply to resources, where applicable"
}
