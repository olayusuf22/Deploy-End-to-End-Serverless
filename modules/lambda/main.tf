# Create a lambda function IAM role
resource "aws_iam_role" "lambda_function_role" {
    name = var.roleName
    assume_role_policy = jsonencode({    
        Version = "2012-10-17"
        Statement = [
        {
            Action : "sts:AssumeRole"
            Effect : "Allow"
            Sid : ""
            Principal = {
                Service = "lambda.amazonaws.com"
            }
        }
        ]
    })
    managed_policy_arns = var.rolePolicies
}

# Zip lambda function code
data "archive_file" "lambda_code_zip" {
    type        = "zip"
    source_file = var.sourceFile
    output_path = var.outputFile
}

# Create a lambda function
resource "aws_lambda_function" "lambda_function" {
    function_name    = var.functionName
    role             = aws_iam_role.lambda_function_role.arn
    handler          = var.handler
    runtime          = var.runtime
    filename         = var.outputFile
    source_code_hash = data.archive_file.lambda_code_zip.output_base64sha256
    layers = var.layers
    environment {
        variables = {
            TABLE_NAME = var.tableName
        }
    }
}
