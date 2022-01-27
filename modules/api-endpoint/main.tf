locals {
  lambda_function_name         = format("%s-%s-%s-lambda-function", var.application, var.environment, var.lambda_function_prefix)
  iam_assume_role_name         = format("%s-%s-%s-assume-role", var.application, var.environment, var.lambda_function_prefix)
  lambda_execution_policy_name = format("%s-%s-%s-lambda-execution-policy", var.application, var.environment, var.lambda_function_prefix)
  lambda_execution_policy_doc  = var.db_permission == "read" ? templatefile("modules/api-endpoint/policy-documents/read-policy.tftpl", { dynamodb-table = var.table_name, log-group = join("-", [var.application, var.environment, "select-all-lambda-function"]) }) : templatefile("modules/api-endpoint/policy-documents/write-policy.tftpl", { dynamodb-table = var.table_name, log-group = join("-", [var.application, var.environment, "select-all-lambda-function"]) })
  iam_assume_role_policy_doc   = file("modules/api-endpoint/policy-documents/assume_policy.json")
  lambda_deployment            = "modules/api-endpoint/functions/deployment.zip"
}

resource "aws_iam_role" "iam_assume_role_for_lambda" {
  name               = local.iam_assume_role_name
  assume_role_policy = local.iam_assume_role_policy_doc
  tags               = var.global_tags

}


resource "aws_iam_policy" "lambda_execution_policy" {
  name        = local.lambda_execution_policy_name
  path        = var.lambda_execution_policy_path
  description = "IAM policy for logging and access dynamodb from a lambda"
  policy      = local.lambda_execution_policy_doc
  tags        = var.global_tags
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_assume_role_for_lambda.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}

resource "aws_lambda_function" "api_backend_lambda" {
  filename         = local.lambda_deployment
  function_name    = local.lambda_function_name
  role             = aws_iam_role.iam_assume_role_for_lambda.arn
  handler          = var.lambda_handler
  timeout          = 10
  runtime          = "python3.8"
  tags             = var.global_tags
  source_code_hash = filebase64sha256(local.lambda_deployment)

  environment {
    variables = {
      REGION     = var.aws_region,
      TABLE_NAME = var.table_name
    }
  }
}


resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = var.api_id
  resource_id   = var.resource_id
  http_method   = var.method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_lambda_integration" {
  rest_api_id             = var.api_id
  resource_id             = var.resource_id
  http_method             = aws_api_gateway_method.api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_backend_lambda.invoke_arn
  depends_on              = [aws_lambda_function.api_backend_lambda, aws_api_gateway_method.api_method]
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.account_id}:${var.api_id}/*/${aws_api_gateway_method.api_method.http_method}${var.api_path}"
  depends_on = [aws_lambda_function.api_backend_lambda]
}

