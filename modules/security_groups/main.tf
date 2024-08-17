# 워커 노드를 위한 보안 그룹 생성
resource "aws_security_group" "worker_group" {
  name_prefix = "${var.cluster_name}-worker_group_mgmt"
  vpc_id      = var.vpc_id

  # SSH 접속을 위한 인바운드 규칙
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}