output "kubeconfig_command" {
  description = "Command to generate kubeconfig file for the cluster"
  value       = "aws eks get-token --cluster-name ${module.eks.cluster_name} | kubectl apply -f -"
}

output "node_groups_iam_role_arns" {
  description = "IAM role ARNs of node groups"
  value       = { for k, v in module.eks.eks_managed_node_groups : k => v.iam_role_arn }
}
#----
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}
output "node_groups" {
  description = "Outputs from EKS node groups"
  value       = module.eks.eks_managed_node_groups
}