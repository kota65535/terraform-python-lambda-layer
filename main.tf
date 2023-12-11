locals {
  output_path = "${coalesce(var.output_dir, path.root)}/${var.name}.zip"
}

resource "terraform_data" "create_lambda_layer" {
  triggers_replace = [var.name, var.output_dir, file(var.requirements_file)]
  provisioner "local-exec" {
    command = "'./${path.module}/scripts/create_lambda_layer.sh' ${var.python_version} ${var.requirements_file} ${local.output_path}"
  }
}

resource "aws_lambda_layer_version" "main" {
  layer_name          = var.name
  filename            = local.output_path
  compatible_runtimes = ["python${regex("^(\\d+\\.\\d+)(\\.\\d+)?", var.python_version)[0]}"]
  source_code_hash    = ""
  lifecycle {
    replace_triggered_by = [terraform_data.create_lambda_layer]
    ignore_changes       = [source_code_hash]
  }
}
