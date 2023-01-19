#!/bin/bash
sudo systemctl start nfs-common.service
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:abhay_cloudWatchconfig_fornodejs
dns_name=efs.us-east-2.amazonaws.com
filesystemId=$(sudo aws efs describe-file-systems --query 'FileSystems[?Name==`abhay-efs`].FileSystemId' | grep fs* | tr --delete '"' | tr --delete ' ')
echo "$filesystemId.$dns_name"
# Mounting Efs 
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport "$filesystemId.$dns_name":/  /var/www/html
# Making Mount Permanent
sudo su
sudo echo "$filesystemId.$dns_name":/ /var/www/html nfs4 defaults,_netdev 0 0  | sudo cat >> /etc/fstab 