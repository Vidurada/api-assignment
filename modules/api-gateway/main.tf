resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = var.description
  endpoint_configuration {
    types = [var.endpoint_type]
  }
  tags = var.global_tags
}

resource "aws_api_gateway_gateway_response" "api_error_response" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  status_code   = "403"
  response_type = "UNAUTHORIZED"

  response_templates = {
    "application/json" = "{\"message\":requested resource not found,\"statusCode\":404 }"
  }

  response_parameters = {
    "gatewayresponse.header.Authorization" = "'Basic'"
  }
}