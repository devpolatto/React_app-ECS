######
## HTTP from net to ECS
######
resource "aws_security_group" "http_sg" {
  name        = "${lookup(var.common_tags, "ALIAS_PROJECT", "sg_public")}-access-public-ecs"
  description = "internet source access"
  vpc_id      = local.vpc_id

  tags = var.common_tags
}

resource "aws_security_group_rule" "http_from_net_rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.http_sg.id
}