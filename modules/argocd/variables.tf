variable "namespace" {
  description = "Kubernetes namespace for ArgoCD"
  default     = "argocd"
}

variable "argocd_version" {
  description = "Version of ArgoCD Helm chart"
  default     = "3.35.4"
}

variable "vpc_id" {
  description = "VPC ID where ArgoCD will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the load balancer"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}