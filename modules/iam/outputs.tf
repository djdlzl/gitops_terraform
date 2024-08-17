output "cluster_iam_role_name" {
  value = aws_iam_role.eks_cluster.name
}

output "cluster_iam_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}