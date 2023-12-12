module "lambda_layer" {
  source            = "../"
  name              = "test"
  python_version    = "3.11.0"
  requirements_path = "requirements.txt"
  output_path       = "${path.root}/test-layer.zip"
}
