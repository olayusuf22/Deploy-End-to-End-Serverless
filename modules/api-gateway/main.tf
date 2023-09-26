# Create API Gateway IAM role
resource "aws_iam_role" "api_gateway_role" {
    name = var.roleName
    assume_role_policy = jsonencode({    
        Version = "2012-10-17"
        Statement = [
        {
            Action : "sts:AssumeRole"
            Effect : "Allow"
            Sid : ""
            Principal = {
                Service = "apigateway.amazonaws.com"
            }
        }
        ]
    })
    managed_policy_arns = var.rolePolicies
}

# Get the region where terraform is executing
data "aws_region" "current" {}

# API Gateway REST API specification
data "template_file" "rest_api_spec" {
    template = "${file(var.restAPISpec)}"
    vars = {
        ExecutionRole = aws_iam_role.api_gateway_role.arn
        Region = data.aws_region.current.name
    }
}

# Create API Gateway REST API
resource "aws_api_gateway_rest_api" "api_gateway" {
    name        = var.apiName
    description = var.apiDescription
    body        = "${data.template_file.rest_api_spec.rendered}"
    endpoint_configuration {
        types = [var.type]
    }
}

# Create API Gateway deployment
resource "aws_api_gateway_deployment" "step-api-gateway-deployment" {
    rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
    stage_name  = var.stageName
}