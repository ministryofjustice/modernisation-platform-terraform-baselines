resource "aws_accessanalyzer_analyzer" "default" {
  analyzer_name = "analyzer"
  type          = "ACCOUNT"
  tags          = var.tags
}

resource "aws_accessanalyzer_analyzer" "unused_access" {
  count         = var.enable_unused_access_analyzer ? 1 : 0
  analyzer_name = var.unused_access_analyzer_name
  type          = "ACCOUNT_UNUSED_ACCESS"
  tags          = var.tags

  configuration {
    unused_access {
      unused_access_age = var.unused_access_age_days
    }
  }
}
