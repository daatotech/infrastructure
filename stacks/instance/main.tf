resource "aws_ecs_cluster" "this" {
  name = local.identifier
}
resource "aws_security_group" "http" {
  name   = "${local.identifier}-http"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = var.api_port
    to_port     = var.api_port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
data "aws_iam_policy_document" "ecs_execution" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role_policy" "private_registry" {
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = ["secretsmanager:GetSecretValue"],
        Effect   = "Allow"
        Resource = [
          aws_secretsmanager_secret.azure_registry.arn
        ]
      }
    ]
  })
  role = aws_iam_role.ecs_execution.id
}
resource "aws_iam_role" "ecs_execution" {
  name               = "${local.identifier}-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution.json
}
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution.name
}