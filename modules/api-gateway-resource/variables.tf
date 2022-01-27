variable "api_id" {
  description = "id of the api"
}

variable "parent_resource_id" {
  description = "id of the parent resource. if path is songs/avg then parent of avg is songs"
}

variable "path" {
  description = "path of the resource. examples /avg /difficulty"
}