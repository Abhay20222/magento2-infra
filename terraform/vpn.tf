#pritunl ec2 instance setup 
locals {
  instance_type = "t3a.small"
  key_name      = "terraform"
}
  
module "pritunl" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "Abhay-Pritunl-Host"

  ami                    = "ami-0ada6d94f396377f2"
  instance_type          = local.instance_type
  key_name               = local.key_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.pritunl-sg.id]
  subnet_id              = element(module.vpc.public_subnets, 0)
  iam_instance_profile   = resource.aws_iam_instance_profile.dev-resources-iam-profile.name


  user_data = filebase64("pritunl.sh")
  tags = {
    Terraform   = "true"
    Environment = "stg"
  }
}

#security group for pritunl
resource "aws_security_group" "pritunl-sg" {
  name = "Pritunl-SG"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 1800
    to_port     = 1800
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Abhay-Pritunl-SG"
    Owner = "Abhay"
  }
}

resource "aws_iam_instance_profile" "dev-resources-iam-profile" {
  name = "my_app_ec2_profile"
  role = aws_iam_role.dev-resources-iam-role.name
}
resource "aws_iam_role" "dev-resources-iam-role" {
  name               = "my_app_dev-ssm-role"
  description        = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
  tags = {
    stack = "test"
  }
}
resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.dev-resources-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
