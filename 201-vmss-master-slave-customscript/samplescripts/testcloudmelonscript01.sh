#!/bin/bash
yum update -y
yum install -y epel-release ansible unzip

echo "installation ok" > /var/log/log.txt
