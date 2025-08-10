output "instance_id" {
  value = aws_instance.test_instance.id
}

output "instance_public_ip" {
  value = aws_eip.test_instance_eip.public_ip
}

output "security_group_id" {
  value = aws_security_group.test_instance_sg.id
}
