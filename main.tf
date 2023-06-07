# Incluye los archivos de configuración
module "vpc" {
  source = "./vpc.tf"
}

module "subnets" {
  source  = "./subnets.tf"
  vpc_id  = module.vpc.vpc_id
}

module "security_groups" {
  source  = "./security_groups.tf"
  vpc_id  = module.vpc.vpc_id
}
