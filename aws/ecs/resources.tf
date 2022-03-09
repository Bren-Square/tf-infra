resource "aws_ecs_cluster" "this" {
  name = var.tier
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/ecs/${var.app_name}"
}

resource "aws_ecs_service" "this" {
  name            = var.app_name
  task_definition = aws_ecs_task_definition.this.arn
  cluster         = aws_ecs_cluster.this.id
  launch_type     = "FARGATE"

  desired_count = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.app_name
    container_port   = "80"
  }

  network_configuration {
    assign_public_ip = false

    security_groups = [
      data.aws_security_group.egress.id,
      data.aws_security_group.ingress.id,
    ]

    subnets = data.aws_subnets.private.ids
  }
}

resource "aws_ecs_task_definition" "this" {
  family = var.app_name

  container_definitions = <<EOF
  [
    {
      "name": "${var.app_name}",
      "image": "${data.aws_ecr_repository.this.repository_url}:${var.container_version}",
      "environment": [
          {
            "name": "ENV_STATE",
            "value": "local"
          }
      ],
      "portMappings": [
        {
          "containerPort": 80
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "${var.aws_region}",
          "awslogs-group": "/ecs/${var.app_name}",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]

EOF

  execution_role_arn       = aws_iam_role.this.arn
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
}

resource "aws_iam_role" "this" {
  name               = "${var.app_name}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}

resource "aws_lb_target_group" "this" {
  name        = var.app_name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.this.id

  health_check {
    enabled = true
    path    = "/api/v1/health"
  }

  depends_on = [aws_alb.this]
}

resource "aws_alb" "this" {
  name               = "${var.app_name}-lb"
  internal           = true
  load_balancer_type = "application"

  subnets = data.aws_subnets.private.ids

  security_groups = [
    data.aws_security_group.http.id,
    data.aws_security_group.https.id,
    data.aws_security_group.egress.id,
  ]

  #depends_on = [aws_internet_gateway.igw]
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.this.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
