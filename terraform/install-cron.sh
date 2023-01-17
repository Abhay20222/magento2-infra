#!/bin/bash
git clone https://github.com/Abhay20222/magento2.git
sudo chown -R www-data:www-data /home/ubuntu/magento2/
sudo chmod -R 755 /home/ubuntu/magento2/
sudo -u www-data /home/ubuntu/magento2/bin/magento cron:install