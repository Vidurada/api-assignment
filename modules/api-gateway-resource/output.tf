output "resource_id" {
  value = aws_api_gateway_resource.api_resource.id
}

output "api_path" {
  value = aws_api_gateway_resource.api_resource.path
}