# Create a basic DynamoDB table
resource "aws_dynamodb_table" "dynamodb_table" {
    name = var.tableName
    read_capacity  = 1
    write_capacity = 1
    hash_key  = var.hashKey
    range_key = var.rangeKey

    attribute {
        name = var.hashKey
        type = "S"
    }

    attribute {
        name = var.rangeKey
        type = "S"
    }
}