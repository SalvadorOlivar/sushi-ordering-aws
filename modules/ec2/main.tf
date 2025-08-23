resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "test_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.test_instance_sg.id]
  tags = {
    Name = var.instance_name
  }
  user_data = <<-EOF
#!/bin/bash
# Esperar a que la instancia tenga red
sleep 15

# Instalar mysql client
sudo dnf install mariadb105 -y

# Crear archivo ~/.my.cnf con los datos de conexión usando variables de Terraform
cat > ~/.my.cnf <<MYCNF
[mysql]
user=${var.db_username}
password=${var.db_password}
host=${var.db_host}
MYCNF

chmod 0600 ~/.my.cnf
  EOF
}

resource "aws_eip" "test_instance_eip" {
  instance = aws_instance.test_instance.id
  domain   = "vpc"
}

resource "aws_security_group" "test_instance_sg" {
  name        = "test_instance_sg"
  description = "Security group for test instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
