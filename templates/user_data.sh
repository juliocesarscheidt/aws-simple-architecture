#!/bin/bash

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
  echo "starting user-data $0"

  sleep 15

  PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
  echo "PRIVATE_IP $PRIVATE_IP"

  yum update -y
  yum install httpd.x86_64 -yt
  systemctl start httpd.service
  systemctl enable httpd.service

  echo "Web Server Running <b>$PRIVATE_IP</b>" | tee /var/www/html/index.html
  echo "Ok" | tee /var/www/html/healthcheck

  systemctl status httpd.service
