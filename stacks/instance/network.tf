data "aws_caller_identity" "main" {}
data "aws_region" "current" {}
data "aws_availability_zones" "all" {
  state = "available"
}
data "aws_route53_zone" "this" {
  name = local.aws_zone
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = var.instance_identifier
  cidr   = "10.0.0.0/16"

  azs                  = data.aws_availability_zones.all.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets     = ["10.0.21.0/24", "10.0.22.0/24"]
  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  database_subnet_tags = { visibility = "database" }
  public_subnet_tags   = { visibility = "public" }
  private_subnet_tags  = { visibility = "private" }
}
resource "aws_alb" "this" {
  name               = "${local.identifier}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.http.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      status_code = "HTTP_301"
      port        = "443"
      protocol    = "HTTPS"
    }
  }
}

resource "aws_lb_listener" "https" {
  depends_on        = [aws_acm_certificate.this]
  load_balancer_arn = aws_alb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.this.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "application/json"
      message_body = jsonencode({
        message = "Hello World!"
      })
      status_code = "200"
    }
  }
}

resource "aws_route53_record" "frontend" {
  name    = local.aws_zone
  type    = "A"
  zone_id = data.aws_route53_zone.this.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_alb.this.dns_name
    zone_id                = aws_alb.this.zone_id
  }
}
resource "aws_route53_record" "api" {
  name    = "api.${local.aws_zone}"
  type    = "A"
  zone_id = data.aws_route53_zone.this.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_alb.this.dns_name
    zone_id                = aws_alb.this.zone_id
  }
}
resource "aws_acm_certificate" "this" {
  domain_name               = local.aws_zone
  subject_alternative_names = ["api.${local.aws_zone}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this.zone_id
}
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}