module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  ami                    = "ami-0ada6d94f396377f2"
  instance_type          = "t3a.micro"
  key_name               = "terraform"
  monitoring             = true
  vpc_security_group_ids = [resource.aws_security_group.Security-elastisearch-abhay.id]
  subnet_id              = module.vpc.private_subnets[0]
  iam_instance_profile   = resource.aws_iam_instance_profile.dev-resources-iam-profile.name
  user_data              = filebase64("install-elastisearch.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "abhay-elastisearch"
  }
}

resource "aws_security_group" "Security-elastisearch-abhay" {
  name        = "security-elastisearch-abhay"
  description = "Allow TLS inbound and outbund traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.pritunl-sg.id]
    #cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    security_groups = [aws_security_group.Security-magento-abhay.id]
    self       = true
    #cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name  = "security-elastisearch-abhay"
    owner = "abhay"
  }
}
