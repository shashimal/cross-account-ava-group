################################################################################
# Setup a VPC
################################################################################
module "vpc" {
  source = "./modules/vpc"

  name               = local.app_name
  azs                = local.azs
  cidr               = local.cidr
  private_subnets    = local.private_subnets
  public_subnets     = local.public_subnets
  database_subnets   = local.database_subnets
  enable_nat_gateway = true
  single_nat_gateway = true
}