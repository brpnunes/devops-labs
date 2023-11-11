
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.main.id
}

resource "aws_network_acl_rule" "public_nacl_inbound_rule" {
  count = length(var.public_allowed_ports)

  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = var.nacl_rule_number_step*(count.index + 1)
  egress         = false
  protocol       = var.public_allowed_ports[count.index].protocol
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = var.public_allowed_ports[count.index].port
  to_port        = var.public_allowed_ports[count.index].port
}

resource "aws_network_acl_rule" "public_nacl_outbound_rule" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = var.nacl_rule_number_step
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_association" "public_nacl" {
  count = length(aws_subnet.public_subnet)

  network_acl_id = aws_network_acl.public_nacl.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}
