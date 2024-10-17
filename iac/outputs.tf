output "api_gateway_url" {
  value = aws_apigatewayv2_api.product_api.api_endpoint
  description = "The URL for invoking the API Gateway"
}