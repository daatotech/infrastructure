resource "aws_cloudwatch_log_group" "api" {
  name = "${local.identifier}-api"
}
resource "aws_ecs_task_definition" "api" {
  family                   = "${local.identifier}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_execution.arn
  container_definitions    = jsonencode([
    {
      name                  = "${local.identifier}-api"
      image                 = "${local.api_image}:${local.identifier}"
      essential             = true
      environment           = [for key, value in local.api_env : { name = key, value = value }]
      repositoryCredentials = {
        credentialsParameter = aws_secretsmanager_secret.azure_registry.arn
      }
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.api_port
          hostPort      = var.api_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          "awslogs-group"         = aws_cloudwatch_log_group.api.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-create-group"  = "true"
          "awslogs-stream-prefix" = "${local.identifier}-api"
        }
      }
    }
  ])
}
resource "aws_lb_target_group" "api" {
  name        = "${local.identifier}-api"
  port        = var.api_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
  health_check {
    path = "/organization/orgIDFromDomain/${split(local.aws_zone, ".")[0]}"
  }
}
resource "aws_alb_listener_rule" "api" {
  listener_arn = aws_lb_listener.https.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
  condition {
    host_header {
      values = ["api.${local.aws_zone}"]
    }
  }
}
resource "aws_ecs_service" "api" {
  name            = "${local.identifier}-api"
  cluster         = aws_ecs_cluster.this.id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.api.arn
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
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "${local.identifier}-api"
    container_port   = var.api_port
  }
}