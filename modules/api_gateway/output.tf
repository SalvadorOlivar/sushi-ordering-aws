## crear outputs para la API Gateway
output "api_endpoint_execution_arn" {
  value = aws_api_gateway_rest_api.api.execution_arn
}