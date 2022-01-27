variable "api_name" {
  description = "name of the api"
}

variable "description" {
  description = "what this api does?"
  default     = "Proxy to handle requests to our API"
}

variable "endpoint_type" {
  description = "type of the api endpoint to use"
  default     = "EDGE"
}

variable "global_tags" {
  description = "Tags to be assigned"
}