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

LOG_FILE="/var/log/cloudera-azure-initialize.log"

EXECNAME=$0
MASTERIP=$1
WORKERIP=$2
NAMEPREFIX=$3
NAMESUFFIX=$4
MASTERNODES=$5
DATANODES=$6
ADMINUSER=$7
NODETYPE=$8

# logs everything to the LOG_FILE
log() {
  echo "$(date) [${EXECNAME}]: $*" >> ${LOG_FILE}
}

function atoi
{
#Returns the integer representation of an IP arg, passed in ascii dotted-decimal notation (x.x.x.x)
IP=$1; IPNUM=0
for (( i=0 ; i<4 ; ++i )); do
((IPNUM+=${IP%%.*}*$((256**$((3-i))))))
IP=${IP#*.}
done
echo $IPNUM
}

function itoa
{
#returns the dotted-decimal ascii form of an IP arg passed in integer format
echo -n $(($(($(($((${1}/256))/256))/256))%256)).
echo -n $(($(($((${1}/256))/256))%256)).
echo -n $(($((${1}/256))%256)).
echo $((${1}%256))
}

log "------- initialize-node.sh starting -------"

log "EXECNAME: $EXECNAME"
log "MASTERIP: $MASTERIP"
log "WORKERIP: $WORKERIP"
log "NAMEPREFIX: $NAMEPREFIX"
log "NAMESUFFIX: $NAMESUFFIX"
log "MASTERNODES: $MASTERNODES"
log "DATANODES: $DATANODES"
log "ADMINUSER: $ADMINUSER"
log "NODETYPE: $NODETYPE"

# Converts a domain like machine.domain.com to domain.com by removing the machine name
NAMESUFFIX=$(echo "$NAMESUFFIX" | sed 's/^[^.]*\.//')

# Generate IP Addresses for the Cloudera setup
log "Generate IP Addresses for the Cloudera setup"
NODES=()

let "NAMEEND=MASTERNODES-1"
for i in $(seq 0 $NAMEEND)
do
  IP=$(atoi "${MASTERIP}")
  let "IP=i+IP"
  HOSTIP=$(itoa "${IP}")
  NODES+=("$HOSTIP:${NAMEPREFIX}-mn$i.$NAMESUFFIX:${NAMEPREFIX}-mn$i")
done

let "DATAEND=DATANODES-1"
for i in $(seq 0 $DATAEND)
do
  IP=$(atoi "${WORKERIP}")
  let "IP=i+IP"
  HOSTIP=$(itoa "${IP}")
  NODES+=("$HOSTIP:${NAMEPREFIX}-dn$i.$NAMESUFFIX:${NAMEPREFIX}-dn$i")
done

OIFS=$IFS
IFS=',';NODE_IPS="${NODES[*]}";IFS=$' \t\n'

IFS=','
for x in $NODE_IPS
do
  line=$(echo "$x" | sed 's/:/ /' | sed 's/:/ /')
  echo "$line" >> /etc/hosts
done
IFS=${OIFS}

log "Done Generate IP Addresses for the Cloudera setup. Host file looks like:"
cat /etc/hosts >> ${LOG_FILE} 2>&1

# Disable the need for a tty when running sudo and allow passwordless sudo for the admin user
sed -i '/Defaults[[:space:]]\+!*requiretty/s/^/#/' /etc/sudoers
echo "$ADMINUSER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Mount and format the attached disks base on node type
log "Mount and format the attached disks for ${NODETYPE}"
if [ "$NODETYPE" == "masternode" ]
then
  bash ./prepare-masternode-disks.sh >> ${LOG_FILE} 2>&1
elif [ "$NODETYPE" == "datanode" ]
then
  bash ./prepare-datanode-disks.sh >> ${LOG_FILE} 2>&1
else
  log "Unknown node type : ${NODETYPE}, default to datanode"
  bash ./prepare-datanode-disks.sh >> ${LOG_FILE} 2>&1
fi

log "Done preparing disks. Now 'ls -la /' looks like this:"
ls -la / >> ${LOG_FILE} 2>&1

# Create Impala scratch directory
log "Create Impala scratch directories"
numDataDirs=$(ls -la / | grep data | wc -l)
log "numDataDirs: $numDataDirs"
let endLoopIter=$((numDataDirs - 1))
for x in $(seq 0 $endLoopIter)
do
  echo mkdir -p /"data${x}"/impala/scratch
  mkdir -p /"data${x}"/impala/scratch
  chmod 777 /"data${x}"/impala/scratch
done

# Disable SELinux
log "Disable SELinux"
setenforce 0 >> /tmp/setenforce.out
cat /etc/selinux/config > /tmp/beforeSelinux.out
sed -i 's^SELINUX=enforcing^SELINUX=disabled^g' /etc/selinux/config || true
cat /etc/selinux/config > /tmp/afterSeLinux.out

# Disable iptables
log "Disable iptables"
/etc/init.d/iptables save
/etc/init.d/iptables stop
chkconfig iptables off

# Install and start NTP
log "Install and start NTP"
yum install -y ntp
service ntpd start
service ntpd status
chkconfig ntpd on

# Disable THP
log "Disable THP"
echo never | tee -a /sys/kernel/mm/transparent_hugepage/enabled
echo "echo never | tee -a /sys/kernel/mm/transparent_hugepage/enabled" | tee -a /etc/rc.local

# Set swappiness to 1
log "Set swappiness to 1"
echo vm.swappiness=1 | tee -a /etc/sysctl.conf
echo 1 | tee /proc/sys/vm/swappiness

# Set system tuning params
log "Set system tuning params"
echo net.ipv4.tcp_timestamps=0 >> /etc/sysctl.conf
echo net.ipv4.tcp_sack=1 >> /etc/sysctl.conf
echo net.core.rmem_max=4194304 >> /etc/sysctl.conf
echo net.core.wmem_max=4194304 >> /etc/sysctl.conf
echo net.core.rmem_default=4194304 >> /etc/sysctl.conf
echo net.core.wmem_default=4194304 >> /etc/sysctl.conf
echo net.core.optmem_max=4194304 >> /etc/sysctl.conf
echo net.ipv4.tcp_rmem="4096 87380 4194304" >> /etc/sysctl.conf
echo net.ipv4.tcp_wmem="4096 65536 4194304" >> /etc/sysctl.conf
echo net.ipv4.tcp_low_latency=1 >> /etc/sysctl.conf
sed -i "s/defaults        1 1/defaults,noatime        0 0/" /etc/fstab

# Set host FQDN
myhostname=$(hostname)
fqdnstring=$(python -c "import socket; print socket.getfqdn('$myhostname')")
log "Set host FQDN to ${fqdnstring}"
sed -i "s/.*HOSTNAME.*/HOSTNAME=${fqdnstring}/g" /etc/sysconfig/network
/etc/init.d/network restart

#disable password authentication in ssh
#sed -i "s/UsePAM\s*yes/UsePAM no/" /etc/ssh/sshd_config
#sed -i "s/PasswordAuthentication\s*yes/PasswordAuthentication no/" /etc/ssh/sshd_config
#/etc/init.d/sshd restart

log "------- initialize-node.sh succeeded -------"

# always `exit 0` on success
exit 0
