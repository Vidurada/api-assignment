resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = var.api_id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_version" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = var.api_id
  stage_name    = var.stage_name
}