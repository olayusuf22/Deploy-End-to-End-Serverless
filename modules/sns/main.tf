# Create a SNS topic
resource "aws_sns_topic" "sns_topic" {
    name = var.topicName 
}
