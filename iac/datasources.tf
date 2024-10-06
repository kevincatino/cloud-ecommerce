data "archive_file" "schema_lambda" {
  type        = "zip"
  source_dir = "lambda/schema/generate_schema"
  output_path = "lambda/schema/generate_schema.zip"
}

data "archive_file" "api_lambda" {
  for_each    = fileset("${path.module}/lambda/api", "*/*.js")
  type        = "zip"
  source_dir = "lambda/api/${split("/", each.value)[0]}"
  output_path = "lambda/api/${split("/", each.value)[0]}.zip"
}

data "aws_caller_identity" "current" {}