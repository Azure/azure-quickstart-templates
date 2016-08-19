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
# Version: 0.2
# Last Modified By: Roy Arsan
# Description:
#  This script sets up a node by configuring pre-installed Splunk Enterprise via Chef in local mode.
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
    echo "This script sets up a node, and configures pre-installed Splunk Enterprise"
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

# Arguments
while getopts :r:p:u:c:i: optname; do
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
    u) #udp port
      UDP_PORT=${OPTARG}
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

# Stop Splunk process & update server & input config
log "Stop Splunk process before configuration"
service splunk stop
/bin/su - splunk -c '/opt/splunk/bin/splunk set servername "${HOSTNAME}"'
/bin/su - splunk -c '/opt/splunk/bin/splunk set default-hostname "${HOSTNAME}"'
# Remove first time login
/bin/su - splunk -c 'touch /opt/splunk/etc/.ui_login'

# Retrieve new list of packages
apt-get -y update

log "Striping data disks into one volume mounted at ${DATA_MOUNTPOINT}"
# Stripe data disks into one data volume where SPLUNK_DB will reside
chmod u+x vm-disk-utils-0.1.sh && ./vm-disk-utils-0.1.sh -s -p $DATA_MOUNTPOINT

# Update Chef data bag with custom user credentials
sed -i "s/notarealpassword/${ADMIN_PASSWD}/" /etc/chef/repo/data_bags/vault/splunk__default.json

# Update Chef placeholder nodes with existing resources data
if [ -n "${CLUSTER_MASTER_IP}" ]; then
  sed -i "s/<INSERT_IP_ADDRESS>/${CLUSTER_MASTER_IP}/" /etc/chef/repo/nodes/cluster-master.json
fi

# Write Chef node file with appropriate role and custom attributes
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
  "run_list": [
    "role[${NODE_ROLE}]"
  ]
}
end

# Write Chef client configs
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

log "Configuring Splunk"
# Finally configure Splunk using chef client in local mode
chef-client -z -c /etc/chef/client.rb -j /etc/chef/node.json

# Cleanup after ourselves - remove chef repo including data bag
rm -rf /etc/chef/repo

log "Finished node-setup on ${HOSTNAME} with role ${NODE_ROLE}"

chmod u+x splunkscript.sh && ./splunkscript.sh $ADMIN_PASSWD $UDP_PORT

exit 0