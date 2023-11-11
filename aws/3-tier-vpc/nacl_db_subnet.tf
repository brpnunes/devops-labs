locals {
  db_subnet_allowed_ports = flatten([
    for subnet in var.db_subnets : [
      for allowed_port in var.db_allowed_ports : {
        subnet_cidr = subnet
        allowed_port = allowed_port
      }
    ]
  ])
}

resource "aws_network_acl" "db_nacl" {
  vpc_id = aws_vpc.main.id
}

resource "aws_network_acl_rule" "db_nacl_inbound_rule" {
  count = length(local.db_subnet_allowed_ports)

  network_acl_id = aws_network_acl.db_nacl.id
  rule_number    = var.nacl_rule_number_step*(count.index + 1)
  egress         = false
  protocol       = local.db_subnet_allowed_ports[count.index].allowed_port.protocol
  rule_action    = "allow"
  cidr_block     = local.db_subnet_allowed_ports[count.index].subnet_cidr
  from_port      = local.db_subnet_allowed_ports[count.index].allowed_port.port
  to_port        = local.db_subnet_allowed_ports[count.index].allowed_port.port
}

resource "aws_network_acl_rule" "db_nacl_outbound_rule" {
  network_acl_id = aws_network_acl.db_nacl.id
  rule_number    = var.nacl_rule_number_step
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_association" "db_nacl" {
  count = length(aws_subnet.db_subnet)

  network_acl_id = aws_network_acl.db_nacl.id
  subnet_id      = aws_subnet.db_subnet[count.index].id
}