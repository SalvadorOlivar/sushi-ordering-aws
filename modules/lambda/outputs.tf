output "lambda_uris" {
  value = { for k, v in aws_lambda_function.service_lambda : k => v.invoke_arn }
}

output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}
