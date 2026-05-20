# ECR module - creates the container registry
module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.project_name
}

# VPC module - creates all networking
module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
}

# ACM module - creates the HTTPS certificate
module "acm" {
  source         = "./modules/acm"
  domain_name    = "tm.${var.domain_name}"
  hosted_zone_id = var.hosted_zone_id
}

# ALB module - creates the load balancer
module "alb" {
  source            = "./modules/alb"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn   = module.acm.certificate_arn
}

# ECS module - runs the container
module "ecs" {
  source                = "./modules/ecs"
  project_name          = var.project_name
  aws_region            = var.aws_region
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  alb_listener_arn      = module.alb.alb_arn
  container_image       = var.container_image
}

# Route 53 record - points tm.paramsingh.co.uk to the ALB
resource "aws_route53_record" "app" {
  zone_id = var.hosted_zone_id
  name    = "tm.${var.domain_name}"
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}