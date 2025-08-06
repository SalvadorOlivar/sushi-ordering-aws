locals {
  lambda_services = {
    menu = {
      function_name = "lambda_menu"
      runtime       = "python3.9"
      filename      = "${path.module}/api/menu.zip"
      handler       = "lambda_function.lambda_handler"
    }
    orders = {
      function_name = "lambda_orders"
      runtime       = "java11"
      filename      = "${path.module}/api/orders.zip"
      handler       = "index.handler"
    }
    users = {
      function_name = "lambda_users"
      runtime       = "nodejs22.x"
      filename      = "${path.module}/api/users.zip"
      handler       = "main"
    }
  }
}