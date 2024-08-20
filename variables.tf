# AWS 리전 설정
variable "region" {
  default = "ap-northeast-3"
}

# VPC CIDR 블록 설정
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# 가용 영역 설정
variable "azs" {
  default = ["ap-northeast-3a", "ap-northeast-3c"]
}

# 프라이빗 서브넷 CIDR 블록 설정
variable "private_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

# 퍼블릭 서브넷 CIDR 블록 설정
variable "public_subnets" {
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

# EKS 클러스터 이름 설정
variable "cluster_name" {
  default = "gitops"
}

# EKS 클러스터 버전 설정
variable "cluster_version" {
  default = "1.30"
}


# EKS 노드 그룹 설정
variable "node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type = map(object({
    name           = string
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = number
  }))
  default = {
    eks_node_gitops = {
      name           = "eks_node_gitops"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      disk_size      = 20
    }
  }
}
# aws-auth ConfigMap에 추가할 IAM 역할 목록
variable "aws_auth_roles" {
  description = "List of role maps to add to the aws-auth configmap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

# aws-auth ConfigMap에 추가할 IAM 사용자 목록
variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}


variable "bastion_key_name" {
  description = "The key name of the Key Pair to use for the bastion instance"
  type        = string
  default     = "gitops_jaewoo_240818"
}