variable "tags" {
  description = "Tags to assign to the Lambda function"
  type        = map(string)
}

variable "db_host" {
  description = "Host de la base de datos RDS"
  type        = string
}

variable "db_user" {
  description = "Usuario de la base de datos"
  type        = string
}

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
}

variable "api_endpoint_execution_arn" {
  description = "ARN de ejecución del endpoint de la API Gateway"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for Lambda VPC configuration"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID del VPC donde se desplegarán los recursos"
  type        = string
}