#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Master script that drives installation and setup of:
# - Basic dependencies
# - Cloudera Director Server, Client, Plugins and dependencies
# - DNS server (bind)
# - MySQL server
#

LOG_FILE=/var/log/azure-template_initialize-server.log

ADMIN_USER=$1
INTERNAL_FQDN_SUFFIX=$2
HOST_IP=$3
MYSQL_USER=$4
MYSQL_PASSWORD=$5

COMPANY=$6
EMAIL_ADDRESS=$7
BUSINESS_PHONE=$8
FIRSTNAME=$9
LASTNAME=${10}
JOBROLE=${11}
JOBFUNCTION=${12}

SLEEP_INTERVAL=10

log() {
  echo "$(date): $*" >> ${LOG_FILE}
}

log "---------- VM extension scripts starting ----------"

#
# Collect marketing info and send it to eloqua.com
#

log "Collecting marketing info ..."

python ./marketing.py -c "${COMPANY}" -e "${EMAIL_ADDRESS}" -b "${BUSINESS_PHONE}" -f "${FIRSTNAME}" -l "${LASTNAME}" -r "${JOBROLE}" -j "${JOBFUNCTION}"

# IMPORTANT: Do NOT fail deployment if marketing info collection failed
status=$?
if [ ${status} -ne 0 ]; then
  log "Collecting marketing info ... Failed";
fi

log "Collecting marketing info ... Successful"

log "Initializing Director Server, DNS server and MySQL DB server ..."

#
# Disable the need for a tty when running sudo and allow passwordless sudo for the admin user
#

log "Enabling password-less sudoer ..."

sed -i '/Defaults[[:space:]]\+!*requiretty/s/^/#/' /etc/sudoers
echo "$ADMIN_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

log "Enabling password-less sudoer ... Successful"

#
# Install wget, Director server and other required packages
#

log "Installing basic tools ..."

sudo yum clean all >> ${LOG_FILE}

# install with retry
n=0
until [ ${n} -ge 5 ]
do
    sudo yum install -y wget expect epel-release>> ${LOG_FILE} 2>&1 && break
    n=$((n+1))
    sleep ${SLEEP_INTERVAL}
done

if [ ${n} -ge 5 ]; then
  log "Installing basic tools ... Failed" & exit 1;
fi

log "Installing basic tools ... Successful"

log "Installing Cloudera Director Server, Client, Plugins and dependencies ..."

sudo wget -t 5 http://archive.cloudera.com/director/redhat/6/x86_64/director/cloudera-director.repo -O /etc/yum.repos.d/cloudera-director.repo >> ${LOG_FILE}
sudo sed -i 's/baseurl=http:\/\/archive.cloudera.com\/director\/redhat\/6\/x86_64\/director\/2\//baseurl=http:\/\/archive.cloudera.com\/director\/redhat\/6\/x86_64\/director\/2.1\//g' /etc/yum.repos.d/cloudera-director.repo

# install with retry
n=0
until [ ${n} -ge 5 ]
do
    sudo yum install -y bind bind-utils python-pip oracle-j2sdk* cloudera-director-server-2.1.* cloudera-director-client-2.1.* >> ${LOG_FILE} 2>&1 && break
    n=$((n+1))
    sleep ${SLEEP_INTERVAL}
done

if [ ${n} -ge 5 ]; then
  log "Installing Cloudera Director Server, Client, Plugins and dependencies ... Failed" & exit 1;
fi

log "Installing Cloudera Director Server, Client, Plugins and dependencies ... Successful"

log "Updating director plugin conf"
cp ./azure-plugin.conf /var/lib/cloudera-director-plugins/azure-provider-1.0.1/etc
chmod 644 /var/lib/cloudera-director-plugins/azure-provider-1.0.1/etc/azure-plugin.conf
cp ./images.conf /var/lib/cloudera-director-plugins/azure-provider-1.0.1/etc
chmod 644 /var/lib/cloudera-director-plugins/azure-provider-1.0.1/etc/images.conf

log "Starting cloudera-director-server ..."

n=0
until [ $n -ge 5 ]
do
    sudo pip install -r requirements.txt >> ${LOG_FILE} 2>&1 && break
    n=$((n+1))
    sleep ${SLEEP_INTERVAL}
done
if [ $n -ge 5 ]; then log "pip install error, exiting..." & exit 1; fi

sudo service cloudera-director-server start

# Check the status of the Director server, wait 5 minutes
n=300
while ! (exec 6<>/dev/tcp/"${HOST_IP}"/7189)
do
    log 'Waiting for director-server to start ...'
    n=$((n-SLEEP_INTERVAL))
    sleep ${SLEEP_INTERVAL}
done

if [ ${n} -le 0 ]; then
  log "Starting cloudera-director-server ... Failed" & exit 1;
fi

log "Starting cloudera-director-server ... Successful"

#
# Disable iptables so API calls to Director server works.
#

log "Disabling iptables ..."

sudo chkconfig iptables off
sudo service iptables stop

log "Disabling iptables ... Successful"

#
# Setup DNS server
#

log "Initializing DNS server ..."

bash ./initialize-dns-server.sh "${INTERNAL_FQDN_SUFFIX}" "${HOST_IP}" "${LOG_FILE}"
status=$?
if [ ${status} -ne 0 ]; then
  log "Initializing DNS server ... Failed" & exit status;
fi

log "Initializing DNS server ... Successful"

#
# Setup MySQL server
#

log "Initializing MySQL server ..."

bash ./initialize-mysql-server.sh "${MYSQL_USER}" "${MYSQL_PASSWORD}" "${LOG_FILE}"
status=$?
if [ ${status} -ne 0 ]; then
  log "Initializing MySQL server ... Failed" & exit status;
fi

log "Initializing MySQL server ... Successful"

log "Initializing Director Server, DNS server and MySQL DB server ... Successful"

exit 0
