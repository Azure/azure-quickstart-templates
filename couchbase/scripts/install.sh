#!/usr/bin/env bash

echo "Running install.sh"

wget http://packages.couchbase.com/releases/4.6.1/couchbase-server-enterprise_4.6.1-ubuntu14.04_amd64.deb

# Using these instructions
# https://developer.couchbase.com/documentation/server/4.6/install/ubuntu-debian-install.html
dpkg -i couchbase-server-enterprise_4.6.1-ubuntu14.04_amd64.deb
apt-get update
apt-get -y install couchbase-server

#Warning: Transparent hugepages looks to be active and should not be.
#Please look at http://bit.ly/1ZAcLjD as for how to PERMANENTLY alter this setting.

#Warning: Swappiness is not set to 0.
#Please look at http://bit.ly/1k2CtNn as for how to PERMANENTLY alter this setting.
