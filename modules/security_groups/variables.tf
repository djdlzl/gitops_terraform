variable "vpc_id" {}
variable "cluster_name" {}
variable "vpc_cidr" {}
variable "cluster_security_group_id" {}

variable "bastion_security_group_id" {
  description = "Security group ID of the bastion host"
  type        = string
}