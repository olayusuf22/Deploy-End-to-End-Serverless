variable "tableName" {
  type = string
  description = "DynamoDB table name"
}

variable "hashKey" {
  type = string
  description = "DynamoDB hash key name"
}

variable "rangeKey" {
  type = string
  description = "DynamoDB range key name"
}