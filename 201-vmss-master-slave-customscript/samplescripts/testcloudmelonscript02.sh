#!/bin/bash
yum update -y
yum install -y epel-release ansible

echo "installation ok" > /var/log/log.txt
