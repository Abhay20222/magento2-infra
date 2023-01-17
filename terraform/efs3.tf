module "efs" {
  source = "terraform-aws-modules/efs/aws"

  # File system
  name           = "abhay-efs"
  creation_token = "abhay-efs-token"
  #encrypted      = true
  #kms_key_arn    = "arn:aws:kms:eu-west-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"

  # File system policy

  # Mount targets / security group
  mount_targets = {
    "${local.region}a" = {
      subnet_id = module.vpc.private_subnets[0]
    }
    "${local.region}b" = {
      subnet_id = module.vpc.private_subnets[1]
    }
    
  }
  
  # Access point(s)
  access_points = {
    posix_abhay-efs = {
      name = "posix-abhay-efs"
      posix_user = {
        gid            = 1001
        uid            = 1001
        secondary_gids = [1002]
      }

      tags = {
        Additionl = "yes"
      }
    }
    root_abhay-efs = {
      root_directory = {
        path = "/var/www/html"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    }
  }

  # Backup policy
  enable_backup_policy = false
}

resource "aws_security_group" "efs-sg" {
   name = "efs-sg"
   description= "Allos inbound efs traffic from ec2"
   vpc_id = module.vpc.vpc_id

   ingress {
     security_groups = [aws_security_group.Security-magento-abhay.id]
     from_port = 2049
     to_port = 2049 
     protocol = "tcp"
   }     
        
   egress {
     security_groups = [aws_security_group.Security-magento-abhay.id]
     from_port = 0
     to_port = 0
     protocol = "-1"
   }
 }