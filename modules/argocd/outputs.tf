output "argocd_url" {
  description = "URL of the ArgoCD server"
  value       = aws_lb.argocd.dns_name
}

# 비밀번호를 안전하게 출력 (선택사항)
output "argocd_initial_password" {
  value     = random_password.argocd_password.result
  sensitive = true
}