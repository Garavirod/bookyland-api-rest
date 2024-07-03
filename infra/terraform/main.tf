module "networking" {
  source = "./modules/networking"
}

module "ecr" {
  source = "./modules/ecr"
}

module "iam" {
  source = "./iam"
}

module "ecs" {
  source          = "./modules/ecs"
  vpc_id          = module.networking.vpc_id
  subnets_id      = module.networking.private_subnets
  cluster_name    = "fastapi-cluster"
  ecr_repository_url = module.ecr.repository_url
  task_role_arn   = module.iam.task_role_arn
  execution_role_arn = module.iam.execution_role_arn
  db_name = var.db_name
  db_password = var.db_password
  db_username = var.db_username
  db_endpoint =  module.rds.db_endpoint
}

module "rds" {
  source              = "./modules/rds"
  vpc_id              = module.networking
  subnet_ids          = module.networking.private_subnets
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  db_instance_class   = var.db_instance_class
}

output "ecs_cluster_id" {
  value = module.ecs.cluster_id
}
