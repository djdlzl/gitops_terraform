resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    templatefile("${path.module}/values.yaml", {
      loadbalancer_ip = aws_lb.argocd.dns_name
    })
  ]

  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = random_password.argocd_password.result
  }
  depends_on = [kubernetes_namespace.argocd, aws_lb.argocd, kubernetes_secret.argocd_password]

  
}

resource "aws_lb" "argocd" {
  name               = "argocd-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.argocd_lb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
}

resource "aws_lb_listener" "argocd" {
  load_balancer_arn = aws_lb.argocd.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.argocd.arn
  }
}

resource "aws_lb_target_group" "argocd" {
  name     = "argocd-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/healthz"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

resource "aws_security_group" "argocd_lb" {
  name        = "argocd-lb-sg"
  description = "Security group for ArgoCD load balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 랜덤 비밀번호 생성
resource "random_password" "argocd_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ArgoCD 초기 관리자 비밀번호를 Kubernetes Secret으로 저장
resource "kubernetes_secret" "argocd_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = {
    password = random_password.argocd_password.result
  }
}