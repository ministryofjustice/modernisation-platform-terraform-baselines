data "aws_regions" "current" {}

resource "local_file" "providers" {
  filename = "${path.module}/providers-generated.tf"
  content  = templatefile("${path.module}/templates/providers.tmpl", { regions : data.aws_regions.current.names })
}

resource "null_resource" "baselines" {
  for_each = toset(local.baselines)

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "aws ssm get-parameters-by-path --path /aws/service/global-infrastructure/services/${each.value}/regions --region=eu-west-2 --output json | jq --unbuffered \"[.Parameters[].Value]\" | tee ${path.module}/regions/${each.value}.json"
  }
}

resource "local_file" "baselines" {
  for_each = toset(local.baselines)
  filename = "${path.module}/${each.value}-generated.tf"
  content = templatefile("${path.module}/templates/${each.value}.tmpl", {
    account_regions : data.aws_regions.current.names,
    service_regions : jsondecode(file("${path.module}/regions/${each.value}.json"))
  })
}
