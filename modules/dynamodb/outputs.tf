output "table_name" {
  value       = aws_dynamodb_table.dynamodb_table.name
  description = "DynamoDB table name"
}