# Create the HTTP API Gateway
resource "aws_apigatewayv2_api" "product_api" {
  name          = "product-api"
  protocol_type = "HTTP"
  description   = "HTTP API for managing products"
}

# Create the Lambda integration
resource "aws_apigatewayv2_integration" "get_user_integration" {
  api_id             = aws_apigatewayv2_api.product_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.api_action["get_user.zip"].invoke_arn
  integration_method = "POST"  # HTTP API Gateway uses POST for AWS_PROXY integrations
}

# Create the route for /user GET
resource "aws_apigatewayv2_route" "get_user_route" {
  api_id    = aws_apigatewayv2_api.product_api.id
  route_key = "GET /user"
  target    = "integrations/${aws_apigatewayv2_integration.get_user_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.product_api.id
  name        = "$default"  # Using the $default stage
  auto_deploy = true        # Enable automatic deployment for all routes
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_action["get_user.zip"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.product_api.execution_arn}/*/*"
}