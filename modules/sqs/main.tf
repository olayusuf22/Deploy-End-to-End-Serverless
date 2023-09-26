# Create SQS queue
resource "aws_sqs_queue" "sqs_queue" {
    name = var.queueName
}

# Create SNS topic subscription for the queue
resource "aws_sns_topic_subscription" "sqs_subscription" {
    protocol             = "sqs"
    raw_message_delivery = false
    topic_arn            = var.snsTopic
    endpoint             = aws_sqs_queue.sqs_queue.arn
}

# Create SQS queue access policy
resource "aws_sqs_queue_policy" "sqs_queue_policy" {
    queue_url = aws_sqs_queue.sqs_queue.id
    policy = <<POLICY
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "",
                    "Effect": "Allow",
                    "Principal": "*",
                    "Action": "sqs:SendMessage",
                    "Resource": "${aws_sqs_queue.sqs_queue.arn}",
                    "Condition": {
                        "ArnEquals": {
                            "aws:SourceArn": "${var.snsTopic}"
                        }
                    }
                }
            ]
        }
    POLICY
}
