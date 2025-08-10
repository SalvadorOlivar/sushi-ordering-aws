resource "aws_lambda_function" "service_lambda" {
  for_each = local.lambda_services

  function_name    = each.value.function_name
  handler          = each.value.handler
  runtime          = each.value.runtime
  role             = aws_iam_role.lambda_exec[each.key].arn
  timeout          = 15

  source_code_hash = filebase64sha256(each.value.filename)
  filename         = each.value.filename
  layers           = each.value.runtime == "python3.9" ? [aws_lambda_layer_version.pymysql-layer.arn] : []

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_HOST     = var.db_host
      DB_USER     = var.db_user
      DB_PASSWORD = var.db_password
      DB_NAME     = var.db_name
    }
  }

  tags = var.tags
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gw" {
  for_each = local.lambda_services
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.service_lambda[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_endpoint_execution_arn}/*/*"
}

resource "aws_iam_role" "lambda_exec" {
  for_each = local.lambda_services
  name     = "${each.value.function_name}_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

## Lambda permissions for RDS access
resource "aws_iam_role_policy" "lambda_rds_access" {
  for_each = local.lambda_services
  name     = "${each.value.function_name}_rds_access_policy"
  role     = aws_iam_role.lambda_exec[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds:*",
          "ec2:*",
          "logs:*",
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

## Create a Lambda Layer for shared code
resource "aws_lambda_layer_version" "pymysql-layer" {
  layer_name = "pymysql-layer"
  compatible_runtimes = ["python3.9"]
  filename = "${path.module}/layers/pymysql-layer.zip"
  source_code_hash = filebase64sha256("${path.module}/layers/pymysql-layer.zip")
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Security group for Lambda functions"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] 
  } 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"] 
  }
}