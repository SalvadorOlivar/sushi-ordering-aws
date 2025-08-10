
variable "subnet_ids" {
  description = "Lista de IDs de subnets para el grupo de subnets de RDS"
  type        = list(string)
}
variable "db_name" {
  description = "Nombre de la base de datos RDS"
  type        = string
}

variable "db_username" {
  description = "Usuario administrador de la base de datos RDS"
  type        = string
}

variable "db_password" {
  description = "Contraseña del usuario administrador de la base de datos RDS"
  type        = string
  sensitive   = true
}

variable "lambda_sg_id" {
  description = "ID del security group de Lambda para permitir acceso en RDS"
  type        = string
}

variable "db_instance_class" {
  description = "Tipo de instancia RDS (db.t3.micro para capa gratuita)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Almacenamiento asignado en GB (20 para capa gratuita)"
  type        = number
  default     = 20
}

variable "db_engine" {
  description = "Motor de base de datos (mysql o postgres)"
  type        = string
  default     = "mysql"
}

variable "db_port" {
  description = "Puerto de la base de datos"
  type        = number
  default     = 3306
}

variable "vpc_id" {
  description = "ID del VPC donde se crea el RDS y el security group"
  type        = string
}