################################################################################
# Setup an ECS application
################################################################################
module "ecs" {
  source = "./modules/ecs"

  app_name         = local.app_name
  vpc_id           = module.vpc.vpc_id
  private_subnets  = module.vpc.private_subnets
  public_subnets   = module.vpc.public_subnets
  environment_list = []
  acm_certificate  = module.acm.acm_certificate_arn
}

################################################################################
# ACM certificate for ava.duleendra.com
################################################################################
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "ava.duleendra.com"
  zone_id     = "xxxxxxxx"
  validation_method = "DNS"
  subject_alternative_names = [
    "*.ava.duleendra.com"
  ]
  wait_for_validation = true
}
