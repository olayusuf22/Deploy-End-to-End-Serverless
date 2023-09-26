variable "roleName" {
  type = string
  description = "Lambda function IAM role name"
}

variable "rolePolicies" {
  type = list(string)
  description = "Lambda function IAM role policies"
}

variable "functionName" {
  type = string
  description = "Lambda function name"
}

variable "sourceFile" {
  type = string
  description = "Lambda source file name"
}

variable "outputFile" {
  type = string
  description = "Lambda output zip file name"
}

variable "handler" {
  type = string
  description = "Lambda function handler"
}

variable "runtime" {
  type = string
  description = "Lambda function runtime"
}

variable "layers" {
  type = list(string)
  description = "Lambda function layers"
}

variable "tableName" {
  type = string
  description = "Lambda DynamoDB table name"
}