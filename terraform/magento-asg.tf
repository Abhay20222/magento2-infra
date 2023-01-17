module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "terraform-asg-abhay"

  min_size                  = 2
  max_size                  = 5
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 60
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  # Launch template
  launch_template_name        = "terraform-lt-abhay"
  launch_template_description = "Launch template example"
  update_default_version      = true

  image_id          = "ami-0f9a2f64910e975ff"
  instance_type     = "t3a.small"
  key_name          = "terraform"
  user_data         = filebase64("fetch-cloudWatch-config.sh")
  ebs_optimized     = true
  enable_monitoring = true
  target_group_arns = module.alb.target_group_arns
  security_groups   = [resource.aws_security_group.Security-magento-abhay.id]
  iam_instance_profile_name = "codedeploy_role_for_ec2"
  # IAM role & instance profile

}
# scaling policy
resource "aws_autoscaling_policy" "asg-policy" {
  
  name                      = "Abhay-asg-cpu-policy"
  autoscaling_group_name    = module.asg.autoscaling_group_name
  estimated_instance_warmup = 60
  policy_type               = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

resource "aws_security_group" "Security-magento-abhay" {
  name        = "security-magento-abhay"
  description = "Allow TLS inbound and outbund traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.pritunl-sg.id]
    #cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.Security-alb-abhay-sg.id]
    #cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    #security_groups = [aws_security_group.efs-sg.id]
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name  = "security-magento-abhay"
    owner = "abhay"
  }
}
