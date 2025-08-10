variable "key_name" {
  description = "Nombre de la clave SSH para EC2"
  type        = string
}

variable "public_key_path" {
  description = "Ruta al archivo de clave pública SSH"
  type        = string
}

variable "ami" {
  description = "AMI para la instancia EC2"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
}

variable "subnet_id" {
  description = "ID de la subred para la instancia EC2"
  type        = string
}

variable "instance_name" {
  description = "Nombre para la instancia EC2"
  type        = string
}

variable "vpc_id" {
  description = "ID del VPC para la instancia EC2"
  type        = string
}
