data "aws_regions" "current" {}

resource "local_file" "providers" {
  filename = "${path.module}/providers-generated.tf"
  content  = templatefile("${path.module}/templates/providers.tmpl", { regions : data.aws_regions.current.names })
}
