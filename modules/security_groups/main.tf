# 워커 노드를 위한 보안 그룹 생성
resource "aws_security_group" "worker_group" {
  name_prefix = "${var.cluster_name}-worker_group_mgmt"
  vpc_id      = var.vpc_id

  # SSH 접속을 위한 인바운드 규칙 (베스천 호스트로부터의 접근 허용)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_security_group_id]
  }

  # 노드 간 모든 통신 허용
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # 쿠버네티스 API 서버 통신 (HTTPS)
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = [var.vpc_cidr]
    security_groups = [var.bastion_security_group_id]
  }

  # kubelet API
  ingress {
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    cidr_blocks     = [var.vpc_cidr]
    security_groups = [var.bastion_security_group_id]
  }

  # 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-worker-sg"
  }
}

# 클러스터 통신을 위한 추가 보안 그룹 규칙
resource "aws_security_group_rule" "cluster_ingress_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group_id
  source_security_group_id = aws_security_group.worker_group.id
  to_port                  = 443
  type                     = "ingress"
}

# 베스천 호스트에서 클러스터 API 서버로의 접근 허용
resource "aws_security_group_rule" "cluster_ingress_bastion_https" {
  description              = "Allow bastion host to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group_id
  source_security_group_id = var.bastion_security_group_id
  to_port                  = 443
  type                     = "ingress"
}