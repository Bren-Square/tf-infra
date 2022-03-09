# Data calls needed for later
data aws_vpc "this" {
  filter {
    name = "tag:Name"
    values = [var.tier]
  }
}

data aws_subnets "public" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    Status = "public"
  }
}

data aws_subnets "private" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    Status = "private"
  }
}

data "aws_acm_certificate" "this" {
  domain   = "*.swigart.io"
  statuses = ["ISSUED"]
}

data "aws_security_group" "ingress" {
  name = "ingress-api"

  filter {
    name = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

data "aws_security_group" "egress" {
  name = "egress-all"

  filter {
    name = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

data "aws_security_group" "http" {
  name = "http"
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

data "aws_security_group" "https" {
  name = "https"
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

data "aws_iam_policy" "ecs_task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# An ECR repository is a private alternative to Docker Hub.
data "aws_ecr_repository" "this" {
  name = "${var.tier}-${var.app_name}"
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


