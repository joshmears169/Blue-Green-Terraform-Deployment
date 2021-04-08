/* Database with read replica in another AZ */

/*resource "aws_db_subnet_group" "DB-Subnet-Group" {
  name        = "db-subnet-group"
  subnet_ids  = var.private_subnet_ids
  
  tags = {
    Project = var.project_name
    Name = "DB-Subnet-Group"
  }
}

resource "aws_db_instance" "test-db" {
  identifier        = "testdb"
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"
  instance_class    = "db.t2.micro"
  name     = var.database_name
  username = var.database_user
  password = var.database_password
  db_subnet_group_name   = aws_db_subnet_group.DB-Subnet-Group.id
  vpc_security_group_ids = [var.database_security_group]
  backup_retention_period = 5
  multi_az = true
  /* Configure the below in actual environment - Skipped snapshot on deletion here for testing purposes */
  /*skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
  
  tags = {
    Project = var.project_name
    Name = "test-db" 
  }
}
/*
resource "aws_db_instance" "Standby-Replica-DB" {
  identifier        = "standbyreplicadb"
  replicate_source_db = aws_db_instance.test-db.identifier
  storage_type      = "gp2"
  instance_class    = "db.t2.micro"
  name     = var.database_name
  vpc_security_group_ids = var.database_security_group
  multi_az = true
  /* Configure the below in actual environment - Skipped snapshot on deletion here for testing purposes */
  /*skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
  
  tags = {
    Name = "Standby-Replica-DB"
    Project = var.project_name
  }
} */
