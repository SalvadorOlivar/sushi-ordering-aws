resource "aws_sqs_queue" "dlq" {
  name                      = "Sushi-Queue-DLQ"
  message_retention_seconds = 1209600 # 14 days
  tags = {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "sqs_queue" {
  name                      = "Sushi-Queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    maxReceiveCount        = 4,
    deadLetterTargetArn    = aws_sqs_queue.dlq.arn
  })

  tags = {
    Environment = "test"
  }
}