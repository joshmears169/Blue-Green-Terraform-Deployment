/* LB Security Group */

resource "aws_security_group" "web-LB" {
  name        = "Web-LB"
  description = "Allow inbound HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.project_name
    Name = "web-LB-sg"
  }
}

resource "aws_security_group_rule" "egress-web-servers" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = aws_security_group.web-servers.id
  security_group_id = aws_security_group.web-LB.id
}

/* Web Servers Security Group */

resource "aws_security_group" "web-servers" {
  name        = "Web-Servers"
  description = "Allow inbound HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Project = var.project_name
    Name = "webserver-sg"
  }
}

resource "aws_security_group_rule" "egress-db" {
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.database-sg.id
  security_group_id = aws_security_group.web-servers.id
}

resource "aws_security_group_rule" "ingress-lb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = aws_security_group.web-LB.id
  security_group_id = aws_security_group.web-servers.id
}

/* Database Security Group to only allow connection to web servers */

resource "aws_security_group" "database-sg" {
  name        = "Database"
  description = "Allow MySQL/Aurora from web server"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.project_name
    Name = "database-sg"
  }
}

resource "aws_security_group_rule" "ingress-webservers" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.web-servers.id
  security_group_id = aws_security_group.database-sg.id
}

/* NACL's for  subnets */

 resource "aws_network_acl" "public_nacl" {
  vpc_id = var.vpc_id
  subnet_ids = var.public_subnet_ids

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Project = var.project_name
    Name = "public-subnet-nacl"
  }
}

resource "aws_network_acl_rule" "egress-public" {
  network_acl_id = aws_network_acl.public_nacl.id
  count       = length(var.subnets_cidr_private)
  rule_number = 200 + count.index
  egress      = true
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = element(var.subnets_cidr_private, count.index)
  from_port   = 3306
  to_port     = 3306
}

resource "aws_network_acl" "private_nacl" {
  vpc_id = var.vpc_id
  subnet_ids = var.private_subnet_ids

   ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  tags = {
    Project = var.project_name
    Name = "private-subnet-nacl"
  }
}

resource "aws_network_acl_rule" "ingress-private" {
  network_acl_id = aws_network_acl.private_nacl.id
  count       = length(var.subnets_cidr_public)
  rule_number = 200 + count.index
  egress      = false
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = element(var.subnets_cidr_public, count.index)
  from_port   = 3306
  to_port     = 3306
}

resource "aws_network_acl_rule" "egress-private" {
  network_acl_id = aws_network_acl.private_nacl.id
  count       = length(var.subnets_cidr_public)
  rule_number = 200 + count.index
  egress      = true
  protocol    = "tcp"
  rule_action = "allow"
  cidr_block  = element(var.subnets_cidr_public, count.index)
  from_port   = 32768
  to_port     = 65535
} 
