module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "terraform-rds-abhay"

  engine                    = "mysql"
  engine_version            = "8.0.28"
  major_engine_version      = "8.0"
  instance_class            = "db.t3.micro"
  allocated_storage         = 20
  storage_type              = "gp2"
  max_allocated_storage     = 100
  db_name                   = "magento"
  availability_zone         = "us-east-2a"
  family                    = "mysql8.0"
  username                  = "admin"
  skip_final_snapshot       = true
  password                  = "password"
  port                      = "3306"
  create_db_option_group    = false
  create_db_parameter_group = false
  vpc_security_group_ids    = [aws_security_group.magento-rdsSG.id]
  create_db_subnet_group    = true
  subnet_ids                = [element(module.vpc.private_subnets, 0), element(module.vpc.private_subnets, 1)]


  tags = {
    Name = "terraform-rds-abhay"
  }
}

## RDS SG
  resource "aws_security_group" "magento-rdsSG" {
  name   = "rds-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description      = "MYSQL/Aurora"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.Security-magento-abhay.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}
####