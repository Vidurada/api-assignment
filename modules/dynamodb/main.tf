resource "aws_dynamodb_table" "api-dynamodb-table" {
  name             = var.table_name
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "id"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "N"
  }

  replica {
    region_name = var.replica_region
  }


  tags = var.global_tags
}