# Create an IAM role for the Step Functions state machine
resource "aws_iam_role" "state_machine_role" {
    name = var.roleName
    assume_role_policy = <<Role1
        {
            "Version" : "2012-10-17",
            "Statement" : [
                {
                "Effect" : "Allow",
                "Principal" : {
                    "Service" : "states.amazonaws.com"
                },
                "Action" : "sts:AssumeRole"
                }
            ]
        }
    Role1
}

# Create an IAM policy for the Step Functions state machine
resource "aws_iam_role_policy" "state_machine_role_policy" {
    role = aws_iam_role.state_machine_role.id
    policy = <<POLICY1
{
"Version" : "2012-10-17",
"Statement" : [
    {
    "Effect" : "Allow",
    "Action" : [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogDelivery",
        "logs:GetLogDelivery",
        "logs:UpdateLogDelivery",
        "logs:DeleteLogDelivery",
        "logs:ListLogDeliveries",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups",
        "cloudwatch:PutMetricData",
        "lambda:InvokeFunction",
        "sns:Publish"
    ],
    "Resource" : "*"
    }
]
}
POLICY1
}

# State machine definition file with the variables to replace
data "template_file" "state_machine_file" {
    template = file(var.stateMachineFile)
    vars = {
        CreateOrderFunction = var.createOrderFunction
        ProcessPaymentFunction = var.processPaymentFunction
        UpdateOrderFunction = var.updateOrderFunction
        UpdateInventoryFunction = var.updateInventoryFunction
        RevertPaymentFunction = var.revertPaymentFunction
        OrdersCompletedSNSTopic = var.ordersCompletedSNSTopic
    }
}

# Explicitly create the Step Function's log group
resource "aws_cloudwatch_log_group" "state_machine_log" {
    name = var.stateMachineLogGroup
}

# Create the AWS Step Functions state machine
resource "aws_sfn_state_machine" "state-machine" {
    name_prefix   = var.stateMachineName
    role_arn      = aws_iam_role.state_machine_role.arn
    definition    = data.template_file.state_machine_file.rendered
    type          = "EXPRESS"
    logging_configuration {
        log_destination = "${aws_cloudwatch_log_group.state_machine_log.arn}:*"
        include_execution_data = true
        level = "ALL"
    }
}
