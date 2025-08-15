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
    # Variables de entorno (deben ser exportadas en el entorno EC2)
    # Crear archivo ~/.my.cnf con los datos de conexión
    cat > ~/.my.cnf <<MYCNF
[mysql]
user=test_user
password=test_password
host=sushi.cytyicikgrsm.us-east-1.rds.amazonaws.com
MYCNF
    chmod 0600 ~/.my.cnf
    # Crear base de datos 'sushi' si no existe
    mysql --defaults-file=~/.my.cnf -e "CREATE DATABASE IF NOT EXISTS sushi;"
    # Crear tabla menu_sushi en la base de datos 'sushi'
    mysql --defaults-file=~/.my.cnf sushi <<SQL
CREATE TABLE IF NOT EXISTS menu_sushi (
id INT AUTO_INCREMENT PRIMARY KEY,
nombre_plato VARCHAR(100) NOT NULL,
precio DECIMAL(10,2) NOT NULL,
descripcion VARCHAR(255),
disponible BOOLEAN DEFAULT TRUE
);
SQL
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
