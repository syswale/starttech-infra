terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Build the Network First
module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
}

# 2. Build the Storage & Cache (Requires Network)
module "storage" {
  source            = "./modules/storage"
  project_name      = var.project_name
  public_subnet_ids = module.networking.public_subnet_ids
  redis_sg_id       = module.networking.redis_sg_id
}

# 3. Build the Compute Backend (Requires Network & Cache)
module "compute" {
  source            = "./modules/compute"
  project_name      = var.project_name
  aws_region        = var.aws_region
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  alb_sg_id         = module.networking.alb_sg_id
  ec2_sg_id         = module.networking.ec2_sg_id
  
  ecr_image_uri     = var.ecr_image_uri
  jwt_secret        = var.jwt_secret
  redis_endpoint    = module.storage.redis_endpoint
  log_group_name    = "/ecs/${var.project_name}-backend"
}