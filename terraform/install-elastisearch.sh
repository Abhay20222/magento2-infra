#!/bin/bash
 sudo apt install apt-transport-https ca-certificates gnupg2 -y
 wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
 sudo sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'
 sudo apt update -y
 sudo apt install elasticsearch -y
 sudo systemctl --now enable elasticsearch
 curl -X GET "localhost:9200"
 sudo sed -i "s/#network.host: .*/network.host: 0.0.0.0/" /etc/elasticsearch/elasticsearch.yml
 sudo sed -i "s/#discovery.seed_hosts: .*/discovery.seed_hosts: ["0.0.0.0"]/" /etc/elasticsearch/elasticsearch.yml
 sudo systemctl restart elasticsearch.service
 # AmazonCloudWatch Agent['/p']
sudo apt update -y
sudo mkdir /tmp/cwa
cd /tmp/cwa
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip -O AmazonCloudWatchAgent.zip
sudo apt install -y unzip
sudo unzip -o AmazonCloudWatchAgent.zip
sudo ./install.sh
sudo mkdir -p /usr/share/collectd/
sudo touch /usr/share/collectd/types.db 
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:abhay_cloudWatchconfig_fornodejs
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
systemctl status amazon-cloudwatch-agent.service