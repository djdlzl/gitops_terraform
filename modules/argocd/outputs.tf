# output "argocd_server_url" {
#   value = "http://${data.kubernetes_service.argocd_server.status.0.load_balancer.0.ingress.0.hostname}"
# }