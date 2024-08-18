output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IP of the bastion host"
}

output "bastion_security_group_id" {
  value       = aws_security_group.bastion.id
  description = "ID of the bastion host security group"
}

output "bastion_iam_instance_profile_arn" {
  value       = aws_iam_instance_profile.bastion.arn
  description = "ARN of the IAM instance profile attached to the bastion host"
}