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
