module "networking" {
  source = "./modules/networking"
}

module "ecr" {
  source = "./modules/ecr"
}
module "secrets" {
  source            = "./modules/secrets"
  database_name     = var.database_name
  database_user     = var.database_user
  database_password = var.database_password
}

module "iam" {
  source                               = "./iam"
  ecr_repository_arn                   = module.ecr.ecr_repository_arn
  secretsmanager_database_name_arn     = module.secrets.secret_database_name_arn
  secretsmanager_database_password_arn = module.secrets.secret_datbase_password_arn
  secretsmanager_database_user_arn     = module.secrets.secret_database_user_arn
}


module "security_group" {
  source = "./modules/security-group"
}

module "load_balancer" {
  source                = "./modules/load-balancer"
  vpc_id                = module.networking.vpc_id
  security_group_ecs_id = module.security_group.ecs_security_group_id
  public_subnets_id      = module.networking.public_subnets_id
}

module "lb_target_group" {
  source            = "./modules/loadbalancer-target-group"
  load_balancer_arn = module.load_balancer.load_balancer_arn
  vpc_id            = module.networking.vpc_id
}

module "ecs" {
  source                 = "./modules/ecs"
  vpc_id                 = module.networking.vpc_id
  subnets_id             = module.networking.private_subnets_id
  cluster_name           = "bookyland-cluster"
  ecr_repository_url     = module.ecr.ecr_respository_url
  task_role_arn          = module.iam.task_role_arn
  execution_role_arn     = module.iam.execution_role_arn
  secret_db_name_arn     = module.secrets.secret_database_name_arn
  secret_db_password_arn = module.secrets.secret_datbase_password_arn
  secret_db_username_arn = module.secrets.secret_database_user_arn
  db_endpoint            = module.rds.db_endpoint
  lb_target_group_arn    = module.lb_target_group.aws_lb_target_group_arn
  ecs_security_group_id  = module.security_group.ecs_security_group_id
}

module "rds" {
  source            = "./modules/rds"
  vpc_id            = module.networking.vpc_id
  subnet_ids        = module.networking.private_subnets_id
  db_name           = var.database_name
  db_username       = var.database_user
  db_password       = var.database_password
  db_instance_class = var.db_instance_class
}

output "ecs_cluster_id" {
  value = module.ecs.ecs_cluster_id
}
