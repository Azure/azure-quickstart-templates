#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2015 Splunk Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Script Name: node-setup.sh
# Author: Roy Arsan - Splunk Inc github:(rarsan)
# Version: 0.1
# Last Modified By: Roy Arsan
# Description:
#  This script sets up a node, and installs & configures Splunk Enterprise via Chef in local mode.
#  The provisioning depends on a specified role and leverages standard Chef Splunk cookbooks
# Parameters :
#  1 - r: role of Splunk server
#  2 - p: password of Splunk server
#  3 - c: cluster master ip address (optional)
#  4 - i: index of node (optional)
#  5 - h: Help
# Note : 
# This script has only been tested on Ubuntu 12.04 LTS & 14.04.2-LTS and must be root

set -e

help()
{
    echo "This script sets up a node, and installs & configures Splunk Enterprise"
    echo "Usage: "
    echo "Parameters:"
    echo "-r role to configure node, supported role(s): splunk_server"
    echo "-p password for Splunk Enterprise admin"
    echo "-c cluster master ip address"
    echo "-i index of node"
    echo "-h help"
}

# Log method to control log output
log()
{
    echo "`date`: $1"
}

# You must be root to run this script
if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

# Parameters
MY_IP="$(ip -4 address show eth0 | sed -rn 's/^[[:space:]]*inet ([[:digit:].]+)[/[:space:]].*$/\1/p')"

DATA_MOUNTPOINT="/datadrive"
SPLUNK_DB_DIR="${DATA_MOUNTPOINT}/splunk_db"

CHEF_PKG_URL="https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/10.04/x86_64/chef_12.5.1-1_amd64.deb"
CHEF_PKG_MD5="6360faba9d6358d636be5618eecb21ee1dbdca7d  chef_12.5.1-1_amd64.deb"
CHEF_PKG_CACHE="/etc/chef/local-mode-cache/cache/chef_12.5.1-1_amd64.deb"
CHEF_GEM_PACKAGE_LOCAL_PATH="`pwd`/chef-vault-2.6.1.gem"
CHEF_REPO_SPLUNK_URL="https://github.com/rarsan/chef-repo-splunk/tarball/v0.8"

# Arguments
while getopts :r:p:c:i: optname; do
  if [ $optname != 'p' ]; then
    log "Option $optname set with value ${OPTARG}"
  fi
  case $optname in
    r) #Role of Splunk by which to configure node
      NODE_ROLE=${OPTARG}
      ;;
    p) #Password of Splunk admin
      ADMIN_PASSWD=${OPTARG}
      ;;
    c) #IP of cluster master
      CLUSTER_MASTER_IP=${OPTARG}
      ;;
    i) #Index of node
      NODE_INDEX=${OPTARG}
      ;;
    h) #Show help
      help
      exit 2
      ;;
    \?) #Unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      help
      exit 2
      ;;
  esac
done

log "Started node-setup on ${HOSTNAME} with role ${NODE_ROLE}"

log "Striping data disks into one volume mounted at ${DATA_MOUNTPOINT}"
# Stripe data disks into one data volume where SPLUNK_DB will reside
chmod u+x vm-disk-utils-0.1.sh && ./vm-disk-utils-0.1.sh -s -p $DATA_MOUNTPOINT

log "Updating system packages"
# Update packages & install required dependencies
apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get install -y curl iptables-persistent

log "Downloading Chef client"
# Download chef client 12.5.1, verify checksum and install package
if [ ! -f "${CHEF_PKG_CACHE}" ]; then
  curl -O ${CHEF_PKG_URL} --retry 3 --retry-delay 10
else
  cp ${CHEF_PKG_CACHE} .
fi

log "Verifying checksum..."
echo ${CHEF_PKG_MD5} > /tmp/checksum
sha1sum -c /tmp/checksum
dpkg -i chef_12.5.1-1_amd64.deb

log "Downloading Chef repo for Splunk"
# Download chef repo including cookbooks, roles and default data bags
mkdir -p /etc/chef/repo
cd /etc/chef/repo
curl -L ${CHEF_REPO_SPLUNK_URL} -o chef-repo-splunk.tar.gz --retry 3 --retry-delay 10
tar -xzf chef-repo-splunk.tar.gz --strip-components=1
tar -xzf berks-package.tar.gz -C cookbooks --strip-components=1
cd -

# Update data bag with custom user credentials
sed -i "s/notarealpassword/${ADMIN_PASSWD}/" /etc/chef/repo/data_bags/vault/splunk__default.json

# Update placeholder nodes with existing resources data
if [ -n "${CLUSTER_MASTER_IP}" ]; then
  sed -i "s/<INSERT_IP_ADDRESS>/${CLUSTER_MASTER_IP}/" /etc/chef/repo/nodes/cluster-master.json
fi

# Setup Chef node file with appropriate role and custom attributes
cat >/etc/chef/node.json <<end
{
  "splunk": {
    "web_port": 10443,
    "ssl_options": {
      "enable_ssl": true,
      "use_default_certs": true
    },
    "server": {
      "runasroot": false,
      "edit_datastore_dir": true,
      "datastore_dir": "${SPLUNK_DB_DIR}"
    }
  },
  "chef-vault": {
    "gem_source": "${CHEF_GEM_PACKAGE_LOCAL_PATH}"
  },
  "run_list": [
    "role[${NODE_ROLE}]"
  ]
}
end

cat >/etc/chef/client.rb <<end
log_level :info
log_location STDOUT
chef_repo_path "/etc/chef/repo"
end

log "Update iptables before running Splunk"
# Port forwarding for system ports: 443->10443, 514->10514
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 443 -j REDIRECT --to-ports 10443
iptables -t nat -A PREROUTING -p udp -m udp --dport 514 -j REDIRECT --to-ports 10514
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 514 -j REDIRECT --to-ports 10514
iptables-save > /etc/iptables/rules.v4
ip6tables -t nat -A PREROUTING -p tcp -m tcp --dport 443 -j REDIRECT --to-ports 10443
ip6tables -t nat -A PREROUTING -p udp -m udp --dport 514 -j REDIRECT --to-ports 10514
ip6tables -t nat -A PREROUTING -p tcp -m tcp --dport 514 -j REDIRECT --to-ports 10514
ip6tables-save > /etc/iptables/rules.v6

log "Installing and configuring Splunk"
# Finally install & configure Splunk using chef client in local mode
chef-client -z -c /etc/chef/client.rb -j /etc/chef/node.json

# Cleanup after ourselves - remove chef repo including data bag
rm -rf /etc/chef/repo

# Remove first time login
touch /opt/splunk/etc/.ui_login

log "Finished node-setup on ${HOSTNAME} with role ${NODE_ROLE}"

exit 0