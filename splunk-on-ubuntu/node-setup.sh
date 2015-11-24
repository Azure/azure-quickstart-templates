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
    echo "$1"
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

MOUNTPOINT="/datadrive"
SPLUNK_DB_DIR="/opt/splunk/var/lib"

CHEF_PKG_URL="https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/10.04/x86_64/chef_12.5.1-1_amd64.deb"
CHEF_PKG_MD5="6360faba9d6358d636be5618eecb21ee1dbdca7d  chef_12.5.1-1_amd64.deb"
CHEF_PKG_CACHE="/etc/chef/local-mode-cache/cache/chef_12.5.1-1_amd64.deb"

CHEF_REPO_URL="https://github.com/rarsan/chef-repo-splunk/tarball/v0.4"

# Arguments
while getopts :r:p:c:i: optname; do
  log "Option $optname set with value ${OPTARG}"
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
    h)  #show help
      help
      exit 2
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      help
      exit 2
      ;;
  esac
done

log "Started node-setup on ${HOSTNAME} with role ${NODE_ROLE}: `date`"

# Stripe data disks into one volume
log "Striping data disks into one volume mounted at ${MOUNTPOINT}"
chmod u+x vm-disk-utils-0.1.sh && ./vm-disk-utils-0.1.sh -s -p ${MOUNTPOINT}

log "Checkpoint 1: `date`"

# Update packages & install dependencies
apt-get -y update && apt-get install -y curl

log "Checkpoint 2: `date`"

# Link SPLUNK_DB to striped volume
log "Create symbolic link from ${MOUNTPOINT}/splunk_db to ${SPLUNK_DB_DIR}/splunk"
mkdir -p $MOUNTPOINT/splunk_db
mkdir -p $SPLUNK_DB_DIR
chmod 777 $MOUNTPOINT/splunk_db
chmod 711 $SPLUNK_DB_DIR
ln -sf $MOUNTPOINT/splunk_db $SPLUNK_DB_DIR/splunk

# Download chef client 12.5.1, verify checksum and install package
if [ ! -f "${CHEF_PKG_CACHE}" ]; then
  curl -O ${CHEF_PKG_URL}
else
  cp ${CHEF_PKG_CACHE} .
fi
echo ${CHEF_PKG_MD5} > /tmp/checksum
sha1sum -c /tmp/checksum
dpkg -i chef_12.5.1-1_amd64.deb

log "Checkpoint 3: `date`"

# Download chef repo including cookbooks, roles and default data bags
mkdir -p /etc/chef/repo
cd /etc/chef/repo
curl -sL ${CHEF_REPO_URL} | tar -xz --strip-components=1
tar -xzf berks-package.tar.gz -C cookbooks --strip-components=1

# Update data bag with custom user credentials
sed -i "s/notarealpassword/${ADMIN_PASSWD}/" /etc/chef/repo/data_bags/vault/splunk__default.json

# Update placeholder nodes with existing resources data
if [ -n "${CLUSTER_MASTER_IP}" ]; then
  sed -i "s/<INSERT_IP_ADDRESS>/${CLUSTER_MASTER_IP}/" /etc/chef/repo/nodes/cluster-master.json
fi

cat >/etc/chef/node.json <<end
{
  "splunk": {
    "ssl_options": {
      "enable_ssl": "true",
      "use_default_certs": "true"
    }
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

log "Checkpoint 4: `date`"

# Finally install & configure Splunk using chef client in local mode
cd -
chef-client -z -c /etc/chef/client.rb -j /etc/chef/node.json

# TODO: Cleanup

log "Finished node-setup on ${HOSTNAME} with role ${NODE_ROLE}: `date`"

exit 0