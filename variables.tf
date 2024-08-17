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
  default = "1.27"
}

# EKS 노드 그룹 설정
variable "node_groups" {
  default = {
    example = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
  }
}