# Create the HTTP API Gateway
resource "aws_apigatewayv2_api" "product_api" {
  name          = "product-api"
  protocol_type = "HTTP"
  description   = "HTTP API for managing products"
}

# Create the Lambda integration for /product
resource "aws_apigatewayv2_integration" "add_product_integration" {
  api_id             = aws_apigatewayv2_api.product_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.api_action["addProduct/index.js"].invoke_arn
  integration_method = "POST"
}


# Create the route for /product POST
resource "aws_apigatewayv2_route" "add_product_route" {
  api_id    = aws_apigatewayv2_api.product_api.id
  route_key = "POST /product"
  target    = "integrations/${aws_apigatewayv2_integration.add_product_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.product_api.id
  name        = "$default"  # Using the $default stage
  auto_deploy = true        # Enable automatic deployment for all routes
}

# Grant API Gateway permission to invoke the Lambda function for /product
resource "aws_lambda_permission" "apigw_lambda_product" {
  statement_id  = "AllowAPIGatewayInvokeProduct"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_action["addProduct/index.js"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.product_api.execution_arn}/*/*"
}