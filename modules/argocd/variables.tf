variable "namespace" {
  description = "Kubernetes namespace for ArgoCD"
  default     = "argocd"
}

variable "argocd_version" {
  description = "Version of ArgoCD Helm chart"
  default     = "5.51.0"
}

variable "admin_password" {
  description = "ArgoCD admin password"
  default     = "It12341!"
}

