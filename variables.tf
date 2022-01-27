variable "aws_primary_region" {
  type = string
  #default = "us-west-2"
}

variable "aws_secondary_region" {
  type = string
  #default = "us-east-1"
}

variable "application" {
  type = string
  #default     = "yousician"
  description = "Name of the application"
}

variable "environment" {
  type = string
  #default     = "dev"
  description = "Application environment"
}

variable "stage" {
  type = string
  #default     = "dev"
  description = "stage/deployment of api"
}