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
  name        = "$default" 
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw_lambda_product" {
  for_each      = aws_lambda_function.api_action
  statement_id  = "AllowAPIGatewayInvokeApiLambda-${regex("^[^/]+", split("_", each.key)[0])}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.product_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  for_each           = { for idx, fn in aws_lambda_function.api_action : fn.function_name => fn }
  api_id             = aws_apigatewayv2_api.product_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = each.value.invoke_arn
  integration_method = "POST"
}


resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id                            = aws_apigatewayv2_api.product_api.id
  name                              = "CognitoAuthorizer"
  authorizer_type                   = "JWT"

  # JWT configuration
  jwt_configuration {
    audience = [aws_cognito_user_pool_client.product_users.id]
    issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.product_users.id}" # Issuer URL for the user pool
  }

  identity_sources = ["$request.header.Authorization"]  # Where to look for the JWT
}

resource "aws_apigatewayv2_route" "lamdba_api_route" {
  for_each  = data.archive_file.api_lambda
  api_id    = aws_apigatewayv2_api.product_api.id
  route_key = replace(split("_", split("/", each.key)[0])[1], ".", "/")
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration[split("_", split("/", each.key)[0])[0]].id}"
   authorization_type = local.lambda_permission_map[split("_", each.key)[0]].requires_auth ? "JWT" : null
  authorizer_id      = local.lambda_permission_map[split("_", each.key)[0]].requires_auth ? aws_apigatewayv2_authorizer.cognito.id : null
  authorization_scopes = local.lambda_permission_map[split("_", each.key)[0]].requires_admin ? ["product-admins"] : []
}

output "lambda_function_keys" {
  value = { for key, _ in data.archive_file.api_lambda : key => local.lambda_permission_map[split("_", key)[0]]}
}

locals {
  lambda_permission_map = {
    "addProduct"                      = { requires_admin = false/*TODO set to true*/, requires_auth = true }
    "addProductImage"                 = { requires_admin = false/*TODO set to true*/, requires_auth = true }
    "bookProduct"                     = { requires_admin = false, requires_auth = true }
    "deleteProduct"                   = { requires_admin = false/*TODO set to true*/, requires_auth = true }
    "getAllProducts"                  = { requires_admin = false, requires_auth = false }
    "getBookings"                     = { requires_admin = false,/*TODO set to true*/ requires_auth = true }
    "redirectLambda"                  = { requires_admin = false, requires_auth = false } 
    }
}