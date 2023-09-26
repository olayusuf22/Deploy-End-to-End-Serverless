# Create a lambda custom layer
resource "aws_lambda_layer_version" "lambda_layer" {
    filename            = var.fileName
    layer_name          = var.layerName
    source_code_hash    = "${filebase64sha256(var.fileName)}"
    compatible_runtimes = [var.runtime]
}