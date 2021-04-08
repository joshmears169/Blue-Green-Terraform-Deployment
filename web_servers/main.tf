/* Blue environment - Web servers */

resource "aws_instance" "webservers-blue" {
  count                  = var.enable_blue_env ? var.blue_instance_count : 0
  ami                    = var.webservers_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.security_group_web_servers]
  subnet_id              = element(var.public_subnet_ids, count.index)
  user_data              = templatefile("${path.module}/user_data.sh", { file_content = "version 1.0 - #${count.index}" })

  tags = {
    Project = var.project_name
    Name = "Blue-Server-${count.index}"
  }
}

resource "aws_lb_target_group" "blue" {
  name     = "blue-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 5
    interval = 10
  }
}

resource "aws_lb_target_group_attachment" "blue" {
  count            = length(aws_instance.webservers-blue)
  target_group_arn = aws_lb_target_group.blue.arn
  target_id        = aws_instance.webservers-blue[count.index].id
  port             = 80
}


/* Green environment - Web servers */


resource "aws_instance" "webservers-green" {
  count                  = var.enable_green_env ? var.green_instance_count : 0
  ami                    = var.webservers_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.security_group_web_servers]
  subnet_id              = element(var.public_subnet_ids, count.index)
  user_data              = templatefile("${path.module}/user_data.sh", { file_content = "version 2.0 - #${count.index}" })

  tags = {
    Project = var.project_name
    Name = "Green-Server-${count.index}"
  }
}

resource "aws_lb_target_group" "green" {
  name     = "green-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 5
    interval = 10
  }
}

resource "aws_lb_target_group_attachment" "green" {
  count            = length(aws_instance.webservers-green)
  target_group_arn = aws_lb_target_group.green.arn
  target_id        = aws_instance.webservers-green[count.index].id
  port             = 80
}