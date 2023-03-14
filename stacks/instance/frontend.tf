resource "aws_cloudwatch_log_group" "frontend" {
  name = "${local.identifier}-frontend"
}
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${local.identifier}-ui"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_execution.arn
  container_definitions    = jsonencode([
    {
      name                  = "${local.identifier}-frontend"
      image                 = "${local.frontend_image}:${local.identifier}"
      essential             = true
      repositoryCredentials = {
        credentialsParameter = aws_secretsmanager_secret.azure_registry.arn
      }
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.frontend_port
          hostPort      = var.frontend_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          "awslogs-group"         = aws_cloudwatch_log_group.frontend.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-create-group"  = "true"
          "awslogs-stream-prefix" = "${local.identifier}-frontend"
        }
      }
    }
  ])
}
resource "aws_lb_target_group" "frontend" {
  name        = "${local.identifier}-frontend"
  port        = var.frontend_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
  health_check {
    path = "/"
  }
}
resource "aws_alb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.https.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
  condition {
    host_header {
      values = ["${local.subdomain}.${local.aws_zone}"]
    }
  }
}
resource "aws_ecs_service" "frontend" {
  name            = "${local.identifier}-frontend"
  cluster         = aws_ecs_cluster.this.id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.frontend.arn
  network_configuration {
    security_groups  = [aws_security_group.http.id]
    subnets          = module.vpc.private_subnets
    assign_public_ip = true
  }
  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 100
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "${local.identifier}-frontend"
    container_port   = var.frontend_port
  }
}