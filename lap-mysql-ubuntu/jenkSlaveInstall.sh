#!/bin/bash
apt-get -y update

#no password prompt while installing mysql server
export DEBIAN_FRONTEND=noninteractive

#install php mysql apache
apt-get -y install mysql-server


