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
    security_group_description = "Example EFS security group"
    security_group_vpc_id      = module.vpc.vpc_id
    security_group_rules = {
     vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = ["10.16.16.0/24", "10.16.17.0/24"]
     }
    }
    attach_policy                      = true
  bypass_policy_lockout_safety_check = false
  policy_statements = [
    {
      sid     = "Example"
      actions = ["elasticfilesystem:ClientMount"]
      principals = [
        {
          type        = "AWS"
          identifiers = ["arn:aws:iam::421320058418:role/abhay-efs-full-acces-role"]
        }
      ]
    }
  ]
  enable_backup_policy = false
}
