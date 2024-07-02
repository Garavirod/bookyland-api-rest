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
  ec2_security_group_name = "SG_for_SSH_and_HTTP"
  vpc_id = module.networking.vpc_bookyland_id
  public_subnet_cicr_blcok = tolist(module.networking.public_subnets_cidr_block)
  security_group_name_for_app = "security_group_bookyland_api_rest"
}

module "ec2" {
  source = "./ec2"
  ami_id = var.ami_id
  instance_type = "t2.micro"
  tag_name = "ec2_bookyland_app"
  public_key = var.public_key
  subnet_id = tolist(module.networking.public_subnets_id)[0]
  public_key_name = "ec2_public_key_baceknd_app"
  sg_enable_ssh_https_id = module.security_group.ec2_ssh_http_security_group_id
  sg_enable_public_ip_address_id = module.security_group.ec2_api_backend_security_group_id
  enable_public_ip_address = true
  user_data_script_install = templatefile("./template/ec2_script_install.sh",{}) // {}: This is an empty dictionary passed as an argument to the templatefile
  ec2_api_backend_security_group_id = module.security_group.ec2_api_backend_security_group_id
}