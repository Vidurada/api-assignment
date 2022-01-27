# Yousician API

Use this repo to create a fully serverless API in AWS. Some important resources used are Lambda, API Gateway and Dynamodb.

#### How to create the infrastructure

##### Prerequisite 
- AWS account.
- User created in the AWS account with required permissions.
- AWS CLI installed and configed with the secrets.

##### Steps to install
1. Clone this repo.
2. Go inside the repo and update the terraform.tfvars configuration file.
3. Execute `terraform init` to install all the modules and plugins.
4. Execute `terraform plan` to check what resources will be created.
5. Execute `terraform apply` to create the resources.
6. After all the resources are created you can see the url of the cloudfront distribution in the command line promt. It will be the url for the API. 

##### Requirements

|  Name |  Version |
| ------------ | ------------ |
| Terraform  | >=1  |
| AWS  |  >=3.48 |


##### terraform.tfvars format

    aws_primary_region = "us-west-2"
    aws_secondary_region = "us-east-1"
    application = "yousician"
    environment = "dev" 
    stage = "dev"

##### Inputs

|  Name |  Description | Type   | Default  |  Required |
| ------------ | ------------ | ------------ | ------------ | ------------ |
|  aws_primary_region  |region to use as primary   | string  | us-west-2  | Yes  |
| aws_secondary_region  |  region to use as secondary | string  |  us-east-1 | Yes  |
| application  |  application name of the API  |   string|  yousician | Yes  |
|  environment | environment of the API  |  string | dev  |  Yes |
|  stage | version of the api  |  string | dev  |  Yes |


