## output rds database host
output "sushi_db" {
  value = aws_db_instance.sushi_db
}