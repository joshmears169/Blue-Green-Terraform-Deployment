output "load_balancer_security_group" {
    value = aws_security_group.web-LB.id
}

output "web_servers_security_group" {
    value = aws_security_group.web-servers.id
}

output "database_security_group" {
    value = aws_security_group.database-sg.id
}