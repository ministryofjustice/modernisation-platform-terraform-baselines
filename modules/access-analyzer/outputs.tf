output "unused_access_analyzer_arn" {
  description = "ARN of the unused access analyzer (empty string if disabled)"
  value       = var.enable_unused_access_analyzer ? aws_accessanalyzer_analyzer.unused_access[0].arn : ""
}
