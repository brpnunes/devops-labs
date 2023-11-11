locals {
  app_subnet_allowed_ports = flatten([
    for subnet in var.app_subnets : [
      for allowed_port in var.app_allowed_ports : {
        subnet_cidr = subnet
        allowed_port = allowed_port
      }
    ]
  ])
}

resource "aws_network_acl" "app_nacl" {
  vpc_id = aws_vpc.main.id
}

resource "aws_network_acl_rule" "app_nacl_inbound_rule" {
  count = length(local.app_subnet_allowed_ports)

  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = var.nacl_rule_number_step*(count.index + 1)
  egress         = false
  protocol       = local.app_subnet_allowed_ports[count.index].allowed_port.protocol
  rule_action    = "allow"
  cidr_block     = local.app_subnet_allowed_ports[count.index].subnet_cidr
  from_port      = local.app_subnet_allowed_ports[count.index].allowed_port.port
  to_port        = local.app_subnet_allowed_ports[count.index].allowed_port.port
}

resource "aws_network_acl_rule" "app_nacl_outbound_rule" {
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = var.nacl_rule_number_step
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_association" "app_nacl" {
  count = length(aws_subnet.app_subnet)

  network_acl_id = aws_network_acl.app_nacl.id
  subnet_id      = aws_subnet.app_subnet[count.index].id
}