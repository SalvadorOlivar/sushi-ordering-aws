variable "api_name" {
  description = "Nombre de la API Gateway"
  type        = string
}

variable "lambda_uri_menu" {
  description = "ARN de la función Lambda para integración AWS_PROXY"
  type        = string
}

variable "lambda_uri_orders" {
  description = "ARN de la función Lambda para integración AWS_PROXY"
  type        = string
}

variable "lambda_uri_users" {
  description = "ARN de la función Lambda para integración AWS_PROXY"
  type        = string
}