locals {
  lambda_services = {
    menu = {
      function_name = "lambda_menu"
      runtime       = "python3.9"
      source_dir    = "${path.module}/api/menu"
      handler       = "lambda_function.lambda_handler"
      filename      = "${path.module}/api/menu/menu.zip"
    }
    orders = {
      function_name = "lambda_orders"
      runtime       = "java11"
      source_dir    = "${path.module}/api/orders"
      handler       = "index.handler"
      filename      = "${path.module}/api/orders/orders.zip"
    }
    users = {
      function_name = "lambda_users"
      runtime       = "nodejs22.x"
      source_dir    = "${path.module}/api/users"
      handler       = "main"
      filename      = "${path.module}/api/users/users.zip"
    }
  }
}