module "networking" {
  source = "./networking"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  cidr_public_subnet = var.cidr_public_subnet
  cidr_private_subnet = var.cidr_private_subnet
  us_availability_zone =  var.us_availability_zone
}


module "security_group" {
  source = "./security-group"
  ec2_security_group_name = "SG for SSH and HTTP"
  vpc_id = module.networking.vpc_bookyland_id
  public_subnet_cicr_blcok = tolist(module.networking.public_subnets_cidr_block)
  security_group_name_for_app = "security_group_bookyland_api_rest"
}

/* module "ec2" {
  source = "./ec2"
  ami_id = var.ami_id
  instance_type = ""
  tag_name = ""
  public_key = var.public_key
  subnet_id = var.subnet_id
  sg_enable_ssh_https = 
} */