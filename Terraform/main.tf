terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Production Remote State using your Account Regional Namespace (-an) bucket
  backend "s3" {
    bucket       = "devops-api-887664351213-us-east-1-an"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Look up your existing ECR repository
data "aws_ecr_repository" "app" {
  name = "devops-api"
}

# 1. Networking Module Call
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name               = "devops-api-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["us-east-1a", "us-east-1b"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  enable_nat_gateway = false
}

# 2. Compute Module Call (Cluster + Fargate Service)
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 6.0"

  cluster_name = "devops-api-cluster"

  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 1
    }
    FARGATE_SPOT = {
      weight = 50
    }
  }

  # Deploys your ECR image onto Fargate
  services = {
    devops-api = {
      cpu    = 256
      memory = 512

      assign_public_ip = true
      subnet_ids       = module.vpc.public_subnets

      security_group_rules = {
        ingress_http = {
          type        = "ingress"
          from_port   = 8000
          to_port     = 8000
          protocol    = "tcp"
          description = "Allow FastAPI traffic on port 8000"
          cidr_blocks = ["0.0.0.0/0"]
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }

      container_definitions = {
        devops-api = {
          essential = true
          image     = "${data.aws_ecr_repository.app.repository_url}:latest"
          port_mappings = [
            {
              name          = "devops-api"
              containerPort = 8000
              hostPort      = 8000
              protocol      = "tcp"
            }
          ]
        }
      }
    }
  }
}