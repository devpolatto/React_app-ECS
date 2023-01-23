resource "aws_subnet" "subnet-public" {
  vpc_id            = local.vpc_id
  cidr_block        = "192.168.30.0/24"
  availability_zone = "${local.region}a"
  tags              = merge(var.common_tags, { Name = "subnet-mnfhsdms" })
}

resource "aws_route_table" "rt-public" {
  vpc_id = local.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.igw_id
  }
  
  tags = merge({ Name = "rt-public" }, var.common_tags, {COMMENT = "Rota de saida para internet"})
}