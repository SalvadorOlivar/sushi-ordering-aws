## crear outputs para la API Gateway
output "api_endpoint_execution_arn" {
  value = aws_apigatewayv2_api.api.execution_arn
}