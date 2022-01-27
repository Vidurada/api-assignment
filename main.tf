/*

file structure

|_ dynamodb
|_ primary api gateway
|_ primary api gateway resources
|_ primary api endpoints
|_ secondary api gateway
|_ secondary api gateway resources
|_ secondary api endpoints
|_ cloudfront
|_ cloudwatch dashboard

*/


locals {
  account_id  = data.aws_caller_identity.current.account_id
  table_name  = format("%s-%s-%s", var.application, var.environment, "table")
  global_tags = { application = var.application, environment = var.environment, CreatedBy = "terraform", OwnedBy = "SRE" }
}

/* ondemand dynamodb with replica in the secondary region */
module "dynamodb" {
  source         = "./modules/dynamodb"
  table_name     = local.table_name
  replica_region = var.aws_secondary_region
  global_tags    = local.global_tags
}

/* primary region api gateway and api resources */
module "api-gateway" {
  source      = "./modules/api-gateway"
  api_name    = format("%s-%s-%s", var.application, var.environment, "api")
  global_tags = local.global_tags
}


module "api-resource-song" {
  source             = "./modules/api-gateway-resource"
  api_id             = module.api-gateway.api_id
  parent_resource_id = module.api-gateway.api_root_resource_id
  path               = "songs"
}

module "api-resource-search" {
  source             = "./modules/api-gateway-resource"
  api_id             = module.api-gateway.api_id
  parent_resource_id = module.api-resource-song.resource_id
  path               = "search"
}

module "api-resource-avg" {
  source             = "./modules/api-gateway-resource"
  api_id             = module.api-gateway.api_id
  parent_resource_id = module.api-resource-song.resource_id
  path               = "avg"
}

module "api-resource-rating" {
  source             = "./modules/api-gateway-resource"
  api_id             = module.api-gateway.api_id
  parent_resource_id = module.api-resource-song.resource_id
  path               = "rating"
}

module "api-resource-difficulty" {
  source             = "./modules/api-gateway-resource"
  api_id             = module.api-gateway.api_id
  parent_resource_id = module.api-resource-avg.resource_id
  path               = "difficulty"
}


/* api endpoints */
module "api-endpoint" {
  source                 = "./modules/api-endpoint"
  lambda_function_prefix = "select-all"
  application            = var.application
  environment            = var.environment
  db_permission          = "read"
  lambda_handler         = "lambda_get_all.lambda_handler"
  aws_region             = var.aws_primary_region
  table_name             = local.table_name
  api_id                 = module.api-gateway.api_id
  method                 = "GET"
  account_id             = local.account_id
  resource_id            = module.api-resource-song.resource_id
  api_path               = module.api-resource-song.api_path
  global_tags            = local.global_tags
}

module "api-endpoint-diff" {
  source                 = "./modules/api-endpoint"
  lambda_function_prefix = "diff-filter"
  application            = var.application
  environment            = var.environment
  db_permission          = "read"
  lambda_handler         = "lambda_filter_difficulty.lambda_handler"
  aws_region             = var.aws_primary_region
  table_name             = local.table_name
  api_id                 = module.api-gateway.api_id
  method                 = "GET"
  account_id             = local.account_id
  resource_id            = module.api-resource-difficulty.resource_id
  api_path               = module.api-resource-difficulty.api_path
  global_tags            = local.global_tags
}

module "api-endpoint-search" {
  source                 = "./modules/api-endpoint"
  lambda_function_prefix = "search"
  application            = var.application
  environment            = var.environment
  db_permission          = "read"
  lambda_handler         = "lambda_search.lambda_handler"
  aws_region             = var.aws_primary_region
  table_name             = local.table_name
  api_id                 = module.api-gateway.api_id
  method                 = "GET"
  account_id             = local.account_id
  resource_id            = module.api-resource-search.resource_id
  api_path               = module.api-resource-search.api_path
  global_tags            = local.global_tags
}

module "api-endpoint-rating" {
  source                 = "./modules/api-endpoint"
  lambda_function_prefix = "rating"
  application            = var.application
  environment            = var.environment
  db_permission          = "read"
  lambda_handler         = "lambda_get_rating.lambda_handler"
  aws_region             = var.aws_primary_region
  table_name             = local.table_name
  api_id                 = module.api-gateway.api_id
  method                 = "GET"
  account_id             = local.account_id
  resource_id            = module.api-resource-rating.resource_id
  api_path               = module.api-resource-rating.api_path
  global_tags            = local.global_tags
}


module "api-endpoint-put-rating" {
  source                 = "./modules/api-endpoint"
  lambda_function_prefix = "put-rating"
  application            = var.application
  environment            = var.environment
  db_permission          = "write"
  lambda_handler         = "lambda_put_rating.lambda_handler"
  aws_region             = var.aws_primary_region
  table_name             = local.table_name
  api_id                 = module.api-gateway.api_id
  method                 = "POST"
  account_id             = local.account_id
  resource_id            = module.api-resource-rating.resource_id
  api_path               = module.api-resource-rating.api_path
  global_tags            = local.global_tags
}

module "api-stage-primary" {
  source     = "./modules/api-stage"
  api_id     = module.api-gateway.api_id
  stage_name = var.stage
  depends_on = [
    module.api-endpoint-put-rating, module.api-endpoint-rating, module.api-endpoint-search,
    module.api-endpoint-diff, module.api-endpoint
  ]
}


/* secondary region api gateway and api resources */
module "api-gateway-secondary" {
  source   = "./modules/api-gateway"
  api_name = format("%s-%s-%s", var.application, var.environment, "api")
  providers = {
    aws = aws.secondary
  }
  global_tags = local.global_tags
}


module "api-resource-song-secondary" {
  source             = "./modules/api-gateway-resource"
  api_id             = module.api-gateway-secondary.api_id
  parent_resource_id = module.api-gateway-secondary.api_root_resource_id
  path               = "song"
  providers = {
    aws = aws.secondary
  }
}

module "api-resource-search-secondary" {
  source             = "./modules/api-gateway-resource"
  api_id             = module.api-gateway-secondary.api_id
  parent_resource_id = module.api-resource-song-secondary.resource_id
  path               = "search"
  providers = {
    aws = aws.secondary
  }
}

module "api-resource-avg-secondary" {
  source             = "./modules/api-gateway-resource"
  api_id             = module.api-gateway-secondary.api_id
  parent_resource_id = module.api-resource-song-secondary.resource_id
  path               = "avg"
  providers = {
    aws = aws.secondary
  }
}

module "api-resource-rating-secondary" {
  source             = "./modules/api-gateway-resource"
  api_id             = module.api-gateway-secondary.api_id
  parent_resource_id = module.api-resource-song-secondary.resource_id
  path               = "rating"
  providers = {
    aws = aws.secondary
  }
}

module "api-resource-difficulty-secondary" {
  source             = "./modules/api-gateway-resource"
  api_id             = module.api-gateway-secondary.api_id
  parent_resource_id = module.api-resource-avg-secondary.resource_id
  path               = "difficulty"
  providers = {
    aws = aws.secondary
  }
}


/* api endpoints */
module "api-endpoint-secondary" {
  source                 = "./modules/api-endpoint"
  lambda_function_prefix = "secondary-select-all"
  application            = var.application
  environment            = var.environment
  db_permission          = "read"
  lambda_handler         = "lambda_get_all.lambda_handler"
  aws_region             = var.aws_secondary_region
  table_name             = local.table_name
  api_id                 = module.api-gateway-secondary.api_id
  method                 = "GET"
  account_id             = local.account_id
  resource_id            = module.api-resource-song-secondary.resource_id
  api_path               = module.api-resource-song-secondary.api_path
  providers = {
    aws = aws.secondary
  }
  global_tags = local.global_tags
}

module "api-endpoint-diff-secondary" {
  source                 = "./modules/api-endpoint"
  lambda_function_prefix = "secondary-diff-filter"
  application            = var.application
  environment            = var.environment
  db_permission          = "read"
  lambda_handler         = "lambda_filter_difficulty.lambda_handler"
  aws_region             = var.aws_secondary_region
  table_name             = local.table_name
  api_id                 = module.api-gateway-secondary.api_id
  method                 = "GET"
  account_id             = local.account_id
  resource_id            = module.api-resource-difficulty-secondary.resource_id
  api_path               = module.api-resource-difficulty-secondary.api_path
  providers = {
    aws = aws.secondary
  }
  global_tags = local.global_tags
}

module "api-endpoint-search-secondary" {
  source                 = "./modules/api-endpoint"
  lambda_function_prefix = "secondary-search"
  application            = var.application
  environment            = var.environment
  db_permission          = "read"
  lambda_handler         = "lambda_search.lambda_handler"
  aws_region             = var.aws_secondary_region
  table_name             = local.table_name
  api_id                 = module.api-gateway-secondary.api_id
  method                 = "GET"
  account_id             = local.account_id
  resource_id            = module.api-resource-search-secondary.resource_id
  api_path               = module.api-resource-search-secondary.api_path
  providers = {
    aws = aws.secondary
  }
  global_tags = local.global_tags
}

module "api-endpoint-rating-secondary" {
  source                 = "./modules/api-endpoint"
  lambda_function_prefix = "secondary-rating"
  application            = var.application
  environment            = var.environment
  db_permission          = "read"
  lambda_handler         = "lambda_get_rating.lambda_handler"
  aws_region             = var.aws_secondary_region
  table_name             = local.table_name
  api_id                 = module.api-gateway-secondary.api_id
  method                 = "GET"
  account_id             = local.account_id
  resource_id            = module.api-resource-rating-secondary.resource_id
  api_path               = module.api-resource-rating-secondary.api_path
  providers = {
    aws = aws.secondary
  }
  global_tags = local.global_tags
}


module "api-endpoint-put-rating-secondary" {
  source                 = "./modules/api-endpoint"
  lambda_function_prefix = "secondary-put-rating"
  application            = var.application
  environment            = var.environment
  db_permission          = "write"
  lambda_handler         = "lambda_put_rating.lambda_handler"
  aws_region             = var.aws_secondary_region
  table_name             = local.table_name
  api_id                 = module.api-gateway-secondary.api_id
  method                 = "POST"
  account_id             = local.account_id
  resource_id            = module.api-resource-rating-secondary.resource_id
  api_path               = module.api-resource-rating-secondary.api_path
  providers = {
    aws = aws.secondary
  }
  global_tags = local.global_tags
}

module "api-stage-secondary" {
  source     = "./modules/api-stage"
  api_id     = module.api-gateway-secondary.api_id
  stage_name = var.environment
  providers = {
    aws = aws.secondary
  }
  depends_on = [
    module.api-endpoint-put-rating-secondary, module.api-endpoint-rating-secondary, module.api-endpoint-search-secondary,
    module.api-endpoint-diff-secondary, module.api-endpoint-secondary
  ]
}


module "cloudfront_distribution" {
  source                     = "./modules/cloudfront"
  primary_api_stage_domain   = format("%s.execute-api.%s.amazonaws.com", module.api-gateway.api_id, var.aws_primary_region)
  primary_api_stage_name     = format("/%s", var.environment)
  secondary_api_stage_domain = format("%s.execute-api.%s.amazonaws.com", module.api-gateway-secondary.api_id, var.aws_secondary_region)
  secondary_api_stage_name   = format("/%s", var.environment)
  global_tags                = local.global_tags

}

module "cloudwatch_dashboard" {
  source = "./modules/cloudwatch"
}
