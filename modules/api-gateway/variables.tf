variable "roleName" {
  type = string
  description = "API Gateway IAM role name"
}

variable "rolePolicies" {
  type = list(string)
  description = "API Gateway IAM role policies"
}

variable "restAPISpec" {
  type = string
  description = "API Gateway REST API specification"
}

variable "apiName" {
  type = string
  description = "API Gateway API name"
}

variable "apiDescription" {
  type = string
  description = "API Gateway API description"
}

variable "type" {
  type = string
  description = "API Gateway type"
}

variable "stageName" {
  type = string
  description = "API Gateway type"
}
