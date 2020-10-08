data "aws_regions" "current" {}

resource "local_file" "providers" {
  filename = "${var.baseline_directory}/${var.baseline_provider_key}/providers.tf"
  content = templatefile("${path.module}/templates/providers.tmpl", {
    account_regions : data.aws_regions.current.names,
    baseline_provider_key : var.baseline_provider_key,
    baseline_assume_role : var.baseline_assume_role
  })
}

resource "null_resource" "baselines" {
  for_each = toset(local.baselines)

  provisioner "local-exec" {
    command = "aws ssm get-parameters-by-path --path /aws/service/global-infrastructure/services/${each.value}/regions --region=eu-west-2 --output json | jq --unbuffered \"[.Parameters[].Value]\" | tee ${path.module}/regions/${each.value}.json"
  }
}

resource "local_file" "baselines" {
  for_each = toset(local.baselines)
  filename = "${var.baseline_directory}/${var.baseline_provider_key}/${each.value}.tf"
  content = templatefile("${path.module}/templates/${each.value}.tmpl", {
    account_regions : data.aws_regions.current.names,
    service_regions : jsondecode(file("${path.module}/regions/${each.value}.json")),
    baseline_provider_key : var.baseline_provider_key
  })
}

resource "local_file" "baseline-variables" {
  filename = "${var.baseline_directory}/${var.baseline_provider_key}/variables.tf"
  content  = file("${path.module}/templates/variables.tf")
}
