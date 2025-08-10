module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name                 = "sushi-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets       = ["10.0.3.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "ec2" {
  source           = "./modules/ec2"
  key_name         = "terraform-key"
  public_key_path  = "keys/id_ed25519.pub"
  ami              = "ami-084a7d336e816906b"
  instance_type    = "t2.micro"
  subnet_id        = module.vpc.public_subnets[0]
  instance_name    = "SushiTestInstance"
  vpc_id           = module.vpc.vpc_id
}

module "api_gateway" {
  source                     = "./modules/api_gateway"
  api_name                   = "sushi"
  lambda_uri_menu            = module.lambda.lambda_uris["menu"]
  lambda_uri_orders          = module.lambda.lambda_uris["orders"]
  lambda_uri_users           = module.lambda.lambda_uris["users"]
}

module "rds" {
  source              = "./modules/rds"
  db_name             = "sushi"
  db_username         = "test_user"
  db_password         = "test_password"
  db_instance_class   = "db.t3.micro"
  db_allocated_storage= 20
  db_engine           = "mysql"
  db_port             = 3306
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnets
  lambda_sg_id        = module.lambda.lambda_sg_id
}

module "lambda" {
  source                       = "./modules/lambda"
  db_host                      = module.rds.sushi_db.address
  db_user                      = "test_user"
  db_password                  = "test_password"
  db_name                      = "sushi"
  api_endpoint_execution_arn   = module.api_gateway.api_endpoint_execution_arn
  subnet_ids                   = module.vpc.private_subnets
  vpc_id                       = module.vpc.vpc_id
  tags = {
    Environment = "Test"
    Project     = "Sushi"
  }
}
