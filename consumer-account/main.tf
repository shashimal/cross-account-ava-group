################################################################################
# Accept the resource share invitation from the owner/central account
################################################################################
resource "aws_ram_resource_share_accepter" "receiver_accept" {
  #arn of Verified Access group resource share created in owner account
  share_arn = "arn:aws:ram:us-east-1:xxxxxx:resource-share/33eea0f3-fe5c-4794-bcf3-e916a9024895"
}

################################################################################
# Setup a Verified Access endpoint with this shared AVA group
################################################################################
resource "aws_verifiedaccess_endpoint" "access_endpoint" {
  description            = "AVA application endpoint"
  application_domain     = local.application_domain

  verified_access_group_id = "vagr-01401808853a9b45d" #Shared AVA group from Owner account

  attachment_type        = "vpc"
  domain_certificate_arn = module.acm.acm_certificate_arn
  endpoint_domain_prefix = "ava"
  endpoint_type          = "load-balancer"

  load_balancer_options {
    load_balancer_arn = module.ecs.alb_arn
    port              = 443
    protocol          = "https"
    subnet_ids        = module.vpc.private_subnets
  }

  security_group_ids       = [module.verified_access_sg.security_group_id]

  tags = {
    Name = "AVA Application"
  }
}

################################################################################
# Security group for Verified Access endpoint
################################################################################
module "verified_access_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name   = "${local.app_name}-verified-access-sg"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_rules = [
    "https-443-tcp"
  ]

  egress_rules = ["all-all"]
}

################################################################################
# Create CNAME record for Verified Access endpoint
################################################################################
module "route53_records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_id = "xxxxxxxx"

  records = [
    {
      name    = "app"
      type    = "CNAME"
      ttl     = 5
      records = [aws_verifiedaccess_endpoint.access_endpoint.endpoint_domain]
    }
  ]
}