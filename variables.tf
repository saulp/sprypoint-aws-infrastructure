# SpryPoint AWS Infrastructure - Variables
# Author: saulperdomo at gmail 2025
# Input variables for the root module

# AWS Configuration
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.aws_region))
    error_message = "AWS region must be a valid region identifier."
  }
}

# Application Configuration
variable "app_name" {
  description = "Application name (used in resource naming)"
  type        = string
  default     = "sprypoint-web"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.app_name))
    error_message = "App name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# Networking Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

# Container Configuration
variable "container_cpu" {
  description = "CPU units for ECS tasks (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 512
  
  validation {
    condition = contains([256, 512, 1024, 2048, 4096], var.container_cpu)
    error_message = "Container CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "container_memory" {
  description = "Memory (MB) for ECS tasks"
  type        = number
  default     = 1024
  
  validation {
    condition = var.container_memory >= 512 && var.container_memory <= 30720
    error_message = "Container memory must be between 512 and 30720 MB."
  }
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 2
  
  validation {
    condition = var.min_capacity >= 1 && var.min_capacity <= 100
    error_message = "Minimum capacity must be between 1 and 100."
  }
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 20
  
  validation {
    condition = var.max_capacity >= 1 && var.max_capacity <= 1000
    error_message = "Maximum capacity must be between 1 and 1000."
  }
}

# Database Configuration
variable "db_instance_class" {
  description = "RDS instance class for Aurora cluster"
  type        = string
  default     = "db.r6g.large"
  
  validation {
    condition = can(regex("^db\\.", var.db_instance_class))
    error_message = "Database instance class must start with 'db.'."
  }
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "sprypoint"
  
  validation {
    condition = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_name))
    error_message = "Database name must start with a letter and contain only letters, numbers, and underscores."
  }
}

# Feature Flags
variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "enable_waf" {
  description = "Enable WAF for Application Load Balancer"
  type        = bool
  default     = true
}

variable "enable_cloudfront" {
  description = "Enable CloudFront CDN"
  type        = bool
  default     = false  # Start simple, add later
}

variable "enable_backup" {
  description = "Enable automated backups for RDS"
  type        = bool
  default     = true
}

# Environment-Specific Overrides
variable "scaling_target_cpu" {
  description = "Target CPU utilization for auto scaling"
  type        = number
  default     = 70
  
  validation {
    condition = var.scaling_target_cpu >= 10 && var.scaling_target_cpu <= 90
    error_message = "Scaling target CPU must be between 10 and 90 percent."
  }
}

variable "health_check_path" {
  description = "Health check path for load balancer"
  type        = string
  default     = "/health"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
  
  validation {
    condition = var.container_port >= 1024 && var.container_port <= 65535
    error_message = "Container port must be between 1024 and 65535."
  }
}

# SSL Configuration
variable "ssl_certificate_arn" {
  description = "ARN of SSL certificate for HTTPS (optional)"
  type        = string
  default     = ""
}

# Monitoring Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
  
  validation {
    condition = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

variable "alert_email" {
  description = "Email address for CloudWatch alerts"
  type        = string
  default     = ""
  
  validation {
    condition = var.alert_email == "" || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.alert_email))
    error_message = "Alert email must be a valid email address or empty string."
  }
}

# Tagging
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "SpryPoint"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}

# Cost Optimization
variable "enable_fargate_spot" {
  description = "Enable Fargate Spot for cost savings (non-production only)"
  type        = bool
  default     = false
}

variable "scheduled_scaling" {
  description = "Enable scheduled scaling (scale down during off-hours)"
  type        = bool
  default     = false
}

# Security Configuration
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the load balancer"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Restrict this in production
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for critical resources"
  type        = bool
  default     = false  # Set to true for production
}
