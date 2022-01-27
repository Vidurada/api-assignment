output "stage_domain" {
  value = aws_api_gateway_stage.api_version.invoke_url
}