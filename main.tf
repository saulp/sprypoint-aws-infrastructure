# SpryPoint AWS Infrastructure - Main Configuration
# Author: saulperdomo at gmail 2025
# This is the root module that orchestrates all infrastructure components

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state backend (configure for your organization)
  backend "s3" {
    # bucket  = "sprypoint-terraform-state"
    # key     = "infrastructure/terraform.tfstate"
    # region  = "us-east-1"
    # encrypt = true
    # 
    # Comment out for local development, uncomment for team usage
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# VPC Module - Network foundation
module "vpc" {
  source = "./modules/vpc"

  app_name    = var.app_name
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  
  # Pass through common tags
  common_tags = var.common_tags
}

# ECS Module - Container orchestration
module "ecs" {
  source = "./modules/ecs"

  app_name         = var.app_name
  environment      = var.environment
  
  # Networking inputs from VPC module
  vpc_id           = module.vpc.vpc_id
  private_subnets  = module.vpc.private_subnet_ids
  public_subnets   = module.vpc.public_subnet_ids
  
  # Container configuration
  container_cpu    = var.container_cpu
  container_memory = var.container_memory
  min_capacity     = var.min_capacity
  max_capacity     = var.max_capacity
  
  # Database connection (from RDS module)
  database_endpoint = module.rds.database_endpoint
  database_name     = var.db_name
  
  common_tags = var.common_tags

  depends_on = [module.vpc, module.rds]
}

# RDS Module - Database layer
module "rds" {
  source = "./modules/rds"

  app_name          = var.app_name
  environment       = var.environment
  
  # Networking inputs from VPC module
  vpc_id            = module.vpc.vpc_id
  database_subnets  = module.vpc.database_subnet_ids
  
  # Database configuration
  db_instance_class = var.db_instance_class
  db_name          = var.db_name
  
  # Security - allow access from ECS
  allowed_security_groups = [module.ecs.ecs_security_group_id]
  
  common_tags = var.common_tags

  depends_on = [module.vpc]
}

# Monitoring Module - Observability
module "monitoring" {
  source = "./modules/monitoring"

  app_name    = var.app_name
  environment = var.environment
  
  # ECS resources to monitor
  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name
  
  # Load balancer to monitor
  load_balancer_arn = module.ecs.load_balancer_arn
  target_group_arn  = module.ecs.target_group_arn
  
  # Database to monitor
  db_cluster_id = module.rds.cluster_id
  
  common_tags = var.common_tags

  depends_on = [module.ecs, module.rds]
}
