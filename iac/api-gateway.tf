# Create the HTTP API Gateway
resource "aws_apigatewayv2_api" "product_api" {
  name          = "product-api"
  protocol_type = "HTTP"
  description   = "HTTP API for managing products"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.product_api.id
  name        = "$default"  # Using the $default stage
  auto_deploy = true        # Enable automatic deployment for all routes
}

resource "aws_lambda_permission" "apigw_lambda_product" {
  for_each      = aws_lambda_function.api_action
  statement_id  =  "AllowAPIGatewayInvokeApiLambda-${regex("^[^/]+", split("_", each.key)[0])}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.product_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  for_each      = { for idx, fn in aws_lambda_function.api_action : fn.function_name => fn }
  api_id             = aws_apigatewayv2_api.product_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = each.value.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "lamdba_api_route" {
  for_each      = data.archive_file.api_lambda
  api_id    = aws_apigatewayv2_api.product_api.id
  route_key = replace(split("_", split("/", each.key)[0])[1], "\\", "/")
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration[split("_", split("/", each.key)[0])[0]].id}"
}