# Create lambda function event source mapping from SQS queue
resource "aws_lambda_event_source_mapping" "lambda_sqs_event_source_mapping" {
    event_source_arn = var.eventSource
    enabled          = true
    function_name    = var.functionName
    batch_size       = 10
}