/* Call Modules */

module "network" {
  source  = "./network"
  vpc_cidr_block = var.vpc_cidr_block
  subnets_cidr_public = var.subnets_cidr_public
  subnets_cidr_private = var.subnets_cidr_private
  azs = var.azs
  project_name = var.project_name
}

module "web_servers" {
  source   = "./web_servers"
  vpc_id = module.network.vpc
  public_subnet_ids = module.network.public_subnet_ids
  security_group_web_servers = module.security.web_servers_security_group
  instance_type = var.instance_type
  webservers_ami = var.webservers_ami
  enable_blue_env = var.enable_blue_env
  blue_instance_count = var.blue_instance_count
  enable_green_env = var.enable_green_env
  green_instance_count = var.green_instance_count
  project_name = var.project_name
  
} 

module "database" {
  source = "./database"
  private_subnet_ids = module.network.private_subnet_ids
  database_security_group = module.security.database_security_group
  database_name     = var.database_name
  database_user     = var.database_user
  database_password = var.database_password
  project_name = var.project_name
}

module "load_balancer" {
  source = "./load_balancer"
  web_lb_security_group = module.security.load_balancer_security_group
  public_subnet_ids = module.network.public_subnet_ids
  blue_target_group = module.web_servers.blue_target_group_arn
  green_target_group = module.web_servers.green_target_group_arn
  traffic_distribution = var.traffic_distribution
  project_name = var.project_name
}

module "security" {
  source = "./security"
  vpc_id = module.network.vpc
  subnets_cidr_public = var.subnets_cidr_public
  subnets_cidr_private = var.subnets_cidr_private
  public_subnet_ids = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  project_name = var.project_name
}