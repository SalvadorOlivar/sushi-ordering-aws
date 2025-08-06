output "lambda_uris" {
  value = { for k, v in aws_lambda_function.service_lambda : k => v.invoke_arn }
}
