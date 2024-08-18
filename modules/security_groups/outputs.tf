output "worker_group_security_group_id" {
  description = "ID of the worker group security group"
  value       = aws_security_group.worker_group.id
}