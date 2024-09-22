# Create the HTTP API Gateway
resource "aws_apigatewayv2_api" "product_api" {
  name          = "product-api"
  protocol_type = "HTTP"
  description   = "HTTP API for managing products"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.product_api.id
  name        = "$default"  # Using the $default stage
  auto_deploy = true        # Enable automatic deployment for all routes
}

resource "aws_lambda_permission" "apigw_lambda_product" {
  for_each      = aws_lambda_function.api_action
  statement_id  =  "AllowAPIGatewayInvokeApiLambda-${regex("^[^/]+", each.key)}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.product_api.execution_arn}/*/*"
}

################################################################################################
#                      POST /products
################################################################################################

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
  route_key = "POST /products"
  target    = "integrations/${aws_apigatewayv2_integration.add_product_integration.id}"
}


################################################################################################
#                      GET /products
################################################################################################

# Create the Lambda integration for /product
resource "aws_apigatewayv2_integration" "get_all_products_integration" {
  api_id             = aws_apigatewayv2_api.product_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.api_action["getAllProducts/index.js"].invoke_arn
  integration_method = "GET"
}

# Create the route for /product POST
resource "aws_apigatewayv2_route" "get_all_products_route" {
  api_id    = aws_apigatewayv2_api.product_api.id
  route_key = "GET /products"
  target    = "integrations/${aws_apigatewayv2_integration.get_all_products_integration.id}"
}

################################################################################################
#                      DELETE /products/{id}
################################################################################################

# Create the Lambda integration for /products/{id}
resource "aws_apigatewayv2_integration" "delete_product_integration" {
  api_id             = aws_apigatewayv2_api.product_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.api_action["deleteProduct/index.js"].invoke_arn
  integration_method = "DELETE"
}

# Create the route for /products/{id} DELETE
resource "aws_apigatewayv2_route" "delete_product_route" {
  api_id    = aws_apigatewayv2_api.product_api.id
  route_key = "DELETE /products/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_product_integration.id}"
}

################################################################################################
#                      GET /bookings
################################################################################################

# Create the Lambda integration for /bookings
resource "aws_apigatewayv2_integration" "get_all_bookings_integration" {
  api_id             = aws_apigatewayv2_api.product_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.api_action["getBookings/index.js"].invoke_arn
  integration_method = "GET"
}

# Create the route for /bookings GET
resource "aws_apigatewayv2_route" "get_all_bookings_route" {
  api_id    = aws_apigatewayv2_api.product_api.id
  route_key = "GET /bookings"
  target    = "integrations/${aws_apigatewayv2_integration.get_all_bookings_integration.id}"
}

################################################################################################
#                      POST /bookings
################################################################################################

# Create the Lambda integration for /product
resource "aws_apigatewayv2_integration" "add_booking_integration" {
  api_id             = aws_apigatewayv2_api.product_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.api_action["bookProduct/index.js"].invoke_arn
  integration_method = "POST"
}

# Create the route for /product POST
resource "aws_apigatewayv2_route" "add_booking_route" {
  api_id    = aws_apigatewayv2_api.product_api.id
  route_key = "POST /products/{id}/bookings"
  target    = "integrations/${aws_apigatewayv2_integration.add_booking_integration.id}"
}
