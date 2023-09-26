terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~>5.11"
        }
    }
}

provider "aws" {}

provider "random" {}

resource "random_string" "random" {
    length = 4
    special = false
}

# Create DynamoDB checkout table
module "dynamodb_table" {
    source = "./modules/dynamodb/"
    tableName = "online-orders-${random_string.random.id}"
    hashKey = "order_id"
    rangeKey = "customer_id"
}

# Create SNS checkout orders completed topic
module "sns_topic" {
    source = "./modules/sns/"
    topicName = "orders-completed-checkout-${random_string.random.id}"
}

# Create SQS orders notification queue
module "sqs_queue_notification" {
    source = "./modules/sqs/"
    queueName = "completed-orders-notification-${random_string.random.id}"
    snsTopic = module.sns_topic.sns_topic_arn
}

# Create SQS orders shipment queue
module "sqs_queue_shipment" {
    source = "./modules/sqs/"
    queueName = "completed-orders-shipment-${random_string.random.id}"
    snsTopic = module.sns_topic.sns_topic_arn
}

# Create checkout python custom lambda layer
module "lambda_layer" {
    source = "./modules/lambda-layer"
    layerName = "python_checkout-${random_string.random.id}"
    fileName = "src/layers/python_checkout.zip"
    runtime = "python3.11"
}

# Create "checkout_create_order" lambda function
module "create_order_lambda_function" {
    source = "./modules/lambda"
    roleName = "create_order_function_role-${random_string.random.id}"
    rolePolicies = [
        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
        "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
    ]
    sourceFile = "src/create_order/lambda_function.py"
    outputFile = "src/create_order/lambda.zip"
    functionName = "checkout_create_order-${random_string.random.id}"
    handler = "lambda_function.lambda_handler"
    runtime = "python3.11"
    layers = [module.lambda_layer.lambda_layer_arn]
    tableName = module.dynamodb_table.table_name
}

# Create "checkout_update_order" lambda function
module "update_order_lambda_function" {
    source = "./modules/lambda"
    roleName = "update_order_function_role-${random_string.random.id}"
    rolePolicies = [
        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
        "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
    ]
    sourceFile = "src/update_order/lambda_function.py"
    outputFile = "src/update_order/lambda.zip"
    functionName = "checkout_update_order-${random_string.random.id}"
    handler = "lambda_function.lambda_handler"
    runtime = "python3.11"
    layers = [module.lambda_layer.lambda_layer_arn]
    tableName = module.dynamodb_table.table_name
}

# Create "checkout_handle_orders_comms" lambda function
module "handle_orders_comms_lambda_function" {
    source = "./modules/lambda"
    roleName = "handle_orders_comms_function_role-${random_string.random.id}"
    rolePolicies = [
        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
        "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
        "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
    ]
    sourceFile = "src/handle_orders_comms/lambda_function.py"
    outputFile = "src/handle_orders_comms/lambda.zip"
    functionName = "checkout_handle_orders_comms-${random_string.random.id}"
    handler = "lambda_function.lambda_handler"
    runtime = "python3.11"
    layers = [module.lambda_layer.lambda_layer_arn]
    tableName = module.dynamodb_table.table_name
}

# Create lambda event source mapping for SQS queue
module "handle_orders_comms_event_source" {
    source = "./modules/event-source"
    eventSource = module.sqs_queue_notification.sqs_queue_arn
    functionName = module.handle_orders_comms_lambda_function.function_arn
}

# Create "checkout_handle_orders_shipment" lambda function
module "handle_orders_shipment_lambda_function" {
    source = "./modules/lambda"
    roleName = "handle_orders_shipment_function_role-${random_string.random.id}"
    rolePolicies = [
        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
        "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
        "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
    ]
    sourceFile = "src/handle_orders_shipment/lambda_function.py"
    outputFile = "src/handle_orders_shipment/lambda.zip"
    functionName = "checkout_handle_orders_shipment-${random_string.random.id}"
    handler = "lambda_function.lambda_handler"
    runtime = "python3.11"
    layers = [module.lambda_layer.lambda_layer_arn]
    tableName = module.dynamodb_table.table_name
}

# Create lambda event source mapping for SQS queue
module "handle_orders_shipment_event_source" {
    source = "./modules/event-source"
    eventSource = module.sqs_queue_shipment.sqs_queue_arn
    functionName = module.handle_orders_shipment_lambda_function.function_arn
}

# Create "checkout_process_payment" lambda function
module "process_payment_lambda_function" {
    source = "./modules/lambda"
    roleName = "process_payment_function_role-${random_string.random.id}"
    rolePolicies = [
        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
        "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
    ]
    sourceFile = "src/process_payment/lambda_function.py"
    outputFile = "src/process_payment/lambda.zip"
    functionName = "checkout_process_payment-${random_string.random.id}"
    handler = "lambda_function.lambda_handler"
    runtime = "python3.11"
    layers = [module.lambda_layer.lambda_layer_arn]
    tableName = module.dynamodb_table.table_name
}

# Create "checkout_revert_payment" lambda function
module "revert_payment_lambda_function" {
    source = "./modules/lambda"
    roleName = "revert_payment_function_role-${random_string.random.id}"
    rolePolicies = [
        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
        "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
    ]
    sourceFile = "src/revert_payment/lambda_function.py"
    outputFile = "src/revert_payment/lambda.zip"
    functionName = "checkout_revert_payment-${random_string.random.id}"
    handler = "lambda_function.lambda_handler"
    runtime = "python3.11"
    layers = [module.lambda_layer.lambda_layer_arn]
    tableName = module.dynamodb_table.table_name
}

# Create "checkout_update_inventory" lambda function
module "update_inventory_lambda_function" {
    source = "./modules/lambda"
    roleName = "update_inventory_function_role-${random_string.random.id}"
    rolePolicies = [
        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
        "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
    ]
    sourceFile = "src/update_inventory/lambda_function.py"
    outputFile = "src/update_inventory/lambda.zip"
    functionName = "checkout_update_inventory-${random_string.random.id}"
    handler = "lambda_function.lambda_handler"
    runtime = "python3.11"
    layers = [module.lambda_layer.lambda_layer_arn]
    tableName = module.dynamodb_table.table_name
}

# Create Step Functions checkout state machine
module "checkout_state_machine" {
    source = "./modules/step-function"
    roleName = "online_checkout_state_machine_role-${random_string.random.id}"
    stateMachineFile = "statemachines/statemachine.asl.json"
    stateMachineName = "online-checkout-state-machine-${random_string.random.id}"
    stateMachineLogGroup = "/aws/vendedlogs/states/online-checkout-state-machine-${random_string.random.id}-Logs"
    createOrderFunction = module.create_order_lambda_function.function_arn
    processPaymentFunction = module.process_payment_lambda_function.function_arn
    updateOrderFunction = module.update_order_lambda_function.function_arn
    updateInventoryFunction = module.update_inventory_lambda_function.function_arn
    revertPaymentFunction = module.revert_payment_lambda_function.function_arn
    ordersCompletedSNSTopic = module.sns_topic.sns_topic_arn
}

# Create API Gateway checkout API 
module "checkout_api_gateway" {
    source = "./modules/api-gateway"
    roleName = "api_gateway_to_step_functions_role-${random_string.random.id}"
    rolePolicies = [
        "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs",
        "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
    ]
    restAPISpec = "src/rest-api/open-api.yaml"
    apiName = "Online Checkout API - ${random_string.random.id}"
    apiDescription = "REST API to invoke checkout workflow state machine"
    type = "REGIONAL"
    stageName = "prod"
}
