# EKS 모듈 사용
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.1.0"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnets         = var.private_subnets
  vpc_id          = var.vpc_id

  # 노드 그룹 설정
  node_groups = var.node_groups
}