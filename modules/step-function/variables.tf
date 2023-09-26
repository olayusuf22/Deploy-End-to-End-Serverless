variable "roleName" {
  type = string
  description = "Step Function IAM role name"
}

variable "stateMachineFile" {
  type = string
  description = "Step Function's state machine ASL file"
}

variable "stateMachineName" {
  type = string
  description = "Step Function's state machine name"
}

variable "stateMachineLogGroup" {
  type = string
  description = "Step Function's state machine log group"
}

variable "createOrderFunction" {
  type = string
  description = "Lambda function ARN"
}

variable "processPaymentFunction" {
  type = string
  description = "Lambda function ARN"
}

variable "updateOrderFunction" {
  type = string
  description = "Lambda function ARN"
}

variable "updateInventoryFunction" {
  type = string
  description = "Lambda function ARN"
}

variable "revertPaymentFunction" {
  type = string
  description = "Lambda function ARN"
}

variable "ordersCompletedSNSTopic" {
  type = string
  description = "SNS topic ARN"
}