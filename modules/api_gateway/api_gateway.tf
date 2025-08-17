resource "aws_api_gateway_rest_api" "api" {
  name = var.api_name
  body = <<EOF
openapi: 3.0.1
info:
  title: Sushi API
  version: 1.0.0
  description: API for managing sushi restaurant operations
paths:
  /v1/menu:
    get:
      summary: Get the menu
      responses:
        '200':
          description: Menu retrieved successfully
      x-amazon-apigateway-integration:
        uri: ${var.lambda_uri_menu}
        httpMethod: POST
        type: aws_proxy
        payloadFormatVersion: 2.0
    post:
      summary: Create a new Menu Item
      responses:
        '200':
          description: Menu item created successfully
      x-amazon-apigateway-integration:
        uri: ${var.lambda_uri_menu}
        httpMethod: POST
        type: aws_proxy
        payloadFormatVersion: 2.0
    delete:
      summary: Delete a Menu Item
      responses:
        '200':
          description: Menu item deleted successfully
      x-amazon-apigateway-integration:
        uri: ${var.lambda_uri_menu}
        httpMethod: POST
        type: aws_proxy
        payloadFormatVersion: 2.0
    options:
      summary: CORS support
      responses:
        '200':
          description: CORS support
          headers:
            Access-Control-Allow-Origin:
              schema:
                type: string
            Access-Control-Allow-Methods:
              schema:
                type: string
            Access-Control-Allow-Headers:
              schema:
                type: string
      x-amazon-apigateway-integration:
        type: mock
        requestTemplates:
          application/json: '{"statusCode": 200}'
        responses:
          default:
            statusCode: '200'
            responseParameters:
              method.response.header.Access-Control-Allow-Methods: "'GET,POST,DELETE,OPTIONS'"
              method.response.header.Access-Control-Allow-Headers: "'Content-Type'"
              method.response.header.Access-Control-Allow-Origin: "'*'"
            responseTemplates:
              application/json: ''
  /v1/orders:
    get:
      summary: Get all orders
      responses:
        '200':
          description: Orders retrieved successfully
      x-amazon-apigateway-integration:
        uri: ${var.lambda_uri_orders}
        httpMethod: POST
        type: aws_proxy
        payloadFormatVersion: 2.0
    put:
      summary: Update an order
      responses:
        '200':
          description: Order updated successfully
      x-amazon-apigateway-integration:
        uri: ${var.lambda_uri_orders}
        httpMethod: POST
        type: aws_proxy
        payloadFormatVersion: 2.0
    post:
      summary: Create a new order
      responses:
        '200':
          description: Order created successfully
      x-amazon-apigateway-integration:
        uri: ${var.lambda_uri_orders}
        httpMethod: POST
        type: aws_proxy
        payloadFormatVersion: 2.0
    delete:
      summary: Delete an order
      responses:
        '200':
          description: Order deleted successfully
      x-amazon-apigateway-integration:
        uri: ${var.lambda_uri_orders}
        httpMethod: POST
        type: aws_proxy
        payloadFormatVersion: 2.0
  /v1/users:
    get:
      summary: Get all users
      responses:
        '200':
          description: Users retrieved successfully
      x-amazon-apigateway-integration:
        uri: ${var.lambda_uri_users}
        httpMethod: POST
        type: aws_proxy
        payloadFormatVersion: 2.0
    put:
      summary: Update a user
      responses:
        '200':
          description: User updated successfully
      x-amazon-apigateway-integration:
        uri: ${var.lambda_uri_users}
        httpMethod: POST
        type: aws_proxy
        payloadFormatVersion: 2.0
    post:
      summary: Create a new user
      responses:
        '200':
          description: User created successfully
      x-amazon-apigateway-integration:
        uri: ${var.lambda_uri_users}
        httpMethod: POST
        type: aws_proxy
        payloadFormatVersion: 2.0
    delete:
      summary: Delete a user
      responses:
        '200':
          description: User deleted successfully
      x-amazon-apigateway-integration:
        uri: ${var.lambda_uri_users}
        httpMethod: POST
        type: aws_proxy
        payloadFormatVersion: 2.0
EOF
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [aws_api_gateway_rest_api.api]
  rest_api_id = aws_api_gateway_rest_api.api.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "test_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "test"
}