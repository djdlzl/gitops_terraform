# AWS 제공자 설정
provider "aws" {
  region = var.region
}

# VPC 모듈 호출
module "vpc" {
  source          = "./modules/vpc"
  region          = var.region
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  cluster_name    = var.cluster_name
}

# EKS 모듈 호출
module "eks" {
  source          = "./modules/eks"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  node_groups     = var.node_groups
}

# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.this.token
# }

# data "aws_eks_cluster_auth" "this" {
#   name = module.eks.cluster_id
# }

# 보안 그룹 모듈 호출
module "security_groups" {
  source       = "./modules/security_groups"
  vpc_id       = module.vpc.vpc_id
  cluster_name = var.cluster_name
}

# IAM 모듈 호출
module "iam" {
  source       = "./modules/iam"
  cluster_name = var.cluster_name
}

# ECR 모듈 호출
module "ecr" {
  source          = "./modules/ecr"
  repository_name = "${var.cluster_name}-repo"
}