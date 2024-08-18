# VPC 모듈 사용
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name                 = "${var.cluster_name}-vpc"
  cidr                 = var.vpc_cidr
  azs                  = var.azs
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # EKS 클러스터를 위한 태그 설정
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

# IAM 모듈 사용
module "iam" {
  source       = "./modules/iam"
  cluster_name = var.cluster_name
}

# EKS 모듈 사용 (이 부분은 EKS 모듈의 구조에 따라 다를 수 있습니다)
module "eks" {
  source          = "./modules/eks"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  node_groups     = local.node_groups

  # IAM 모듈에서 생성한 역할 ARN 사용
  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_group_role_arn

  aws_auth_roles = var.aws_auth_roles
  aws_auth_users = var.aws_auth_users

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "kube-system"
        },
        {
          namespace = "default"
        }
      ]
    }
  }
}

# Move aws_auth ConfigMap management here
resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(
      concat(
        [for key, node_group in module.eks.node_groups : {
          rolearn  = node_group.iam_role_arn
          username = "system:node:{{EC2PrivateDNSName}}"
          groups   = ["system:bootstrappers", "system:nodes"]
        }],
        [{
          rolearn  = module.bastion.bastion_iam_instance_profile_arn
          username = "system:node:{{EC2PrivateDNSName}}"
          groups   = ["system:masters"]
        }],
        var.aws_auth_roles
      )
    )
    mapUsers = yamlencode(var.aws_auth_users)
  }

  force = true
}
# 노드 그룹 정의를 동적으로 생성
locals {
  node_groups = {
    for key, group in var.node_groups :
    key => merge(group, {
      iam_role_arn = module.iam.eks_node_group_role_arn
    })
  }
}
data "aws_caller_identity" "current" {}
# Security Group 모듈 사용

module "security_groups" {
  source                      = "./modules/security_groups"
  vpc_id                      = module.vpc.vpc_id
  cluster_name                = var.cluster_name
  vpc_cidr                    = var.vpc_cidr
  cluster_security_group_id   = module.eks.cluster_security_group_id
  bastion_security_group_id   = module.bastion.bastion_security_group_id
}
# ECR 모듈 호출
module "ecr" {
  source          = "./modules/ecr"
  repository_name = "${var.cluster_name}-repo"
}


resource "null_resource" "generate_kubeconfig" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = <<-EOT
      aws eks wait cluster-active --name ${var.cluster_name} --region ${var.region}
      aws eks get-token --cluster-name ${var.cluster_name} --region ${var.region}
      aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}
    EOT
  }
}

resource "null_resource" "update_kubeconfig" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = <<-EOT
      aws eks wait cluster-active --name ${var.cluster_name} --region ${var.region}
      aws eks get-token --cluster-name ${var.cluster_name} --region ${var.region}
      aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}
    EOT
  }
}

module "bastion" {
  source = "./modules/bastion"

  cluster_name  = var.cluster_name
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnets[0]
  ami_id        = "ami-0d979355d03fa2522"  # Amazon Linux 2 AMI (ap-northeast-3 리전)
  key_name      = "gitops_jaewoo_240818"
  region        = var.region
}



module "argocd" {
  source            = "./modules/argocd"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets
  cluster_name      = module.eks.cluster_name

  depends_on = [module.eks]
}