resource "aws_security_group" "bastion" {
  name        = "${var.cluster_name}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-bastion-sg"
  }
}
data "aws_ami" "ubuntu_22_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu_22_04.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = var.subnet_id

  associate_public_ip_address = true

  tags = {
    Name = "${var.cluster_name}-bastion"
  }

  user_data = <<-EOF
              #!/bin/bash
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              echo "Starting user data script execution"
              
              # 시스템 업데이트 및 필요한 패키지 설치
              echo "Updating system and installing necessary packages"
              sudo apt-get update && sudo apt-get upgrade -y
              sudo apt-get install -y unzip curl wget

              echo "Installing AWS CLI"
              # AWS CLI 최신 버전 설치
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install
              
              echo "Installing kubectl"
      # kubectl 최신 버전 설치
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      chmod +x kubectl
      sudo mv kubectl /usr/local/bin/
      
      echo "Installing aws-iam-authenticator"
      # aws-iam-authenticator 설치
      curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_amd64
      chmod +x aws-iam-authenticator
      sudo mv aws-iam-authenticator /usr/local/bin/
      
      echo "Configuring AWS CLI"
      # AWS CLI 구성
      mkdir -p /home/ubuntu/.aws
      echo "[default]" > /home/ubuntu/.aws/config
      echo "region = ${var.region}" >> /home/ubuntu/.aws/config
      
      echo "Configuring kubeconfig"
      # kubeconfig 생성 및 업데이트
      sudo -u ubuntu aws eks get-token --cluster-name ${var.cluster_name} --region ${var.region} > /dev/null 2>&1
      sudo -u ubuntu aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}
      
      echo "Setting permissions"
      # 파일 권한 설정
      chown -R ubuntu:ubuntu /home/ubuntu/.kube /home/ubuntu/.aws
      
      echo "Setting environment variables"
      # 환경 변수 설정
      echo "export KUBECONFIG=/home/ubuntu/.kube/config" >> /home/ubuntu/.bashrc
      
      echo "User data script execution completed"
      EOF

  iam_instance_profile = aws_iam_instance_profile.bastion.name
}

resource "aws_iam_role" "bastion" {
  name = "${var.cluster_name}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


# IAM 역할에 필요한 정책 추가
resource "aws_iam_role_policy_attachment" "bastion_eks_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.bastion.name
}

resource "aws_iam_role_policy" "bastion_eks_console_access" {
  name = "eks-console-access"
  role = aws_iam_role.bastion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumesModifications",
          "ec2:DescribeVpcs",
          "iam:ListInstanceProfiles"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "bastion_eks_admin" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.bastion.name
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.cluster_name}-bastion-instance-profile"
  role = aws_iam_role.bastion.name
}

resource "aws_iam_role_policy" "bastion_eks_access" {
  name = "eks-full-access"
  role = aws_iam_role.bastion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumesModifications",
          "ec2:DescribeVpcs",
          "iam:ListInstanceProfiles",
          "iam:GetInstanceProfile"
        ]
        Resource = "*"
      }
    ]
  })
}