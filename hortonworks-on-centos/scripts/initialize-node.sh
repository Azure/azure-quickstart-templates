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

IPPREFIX=$1
NAMEPREFIX=$2
NAMESUFFIX=$3
NAMENODES=$4
DATANODES=$5

# Converts a domain like machine.domain.com to domain.com by removing the machine name
NAMESUFFIX=`echo $NAMESUFFIX | sed 's/^[^.]*\.//'`

#disable the need for a tty when running sudo
sed -i '/Defaults[[:space:]]\+!*requiretty/s/^/#/' /etc/sudoers

# Disable SELinux
/usr/sbin/setenforce 0
sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/selinux/config

# Do not start iptables on boot
chkconfig iptables off

# Start ntpd on boot
chkconfig ntpd on

# Install ambari
sudo yum install -y epel-release
sudo wget http://public-repo-1.hortonworks.com/ambari/centos6/2.x/updates/2.0.0/ambari.repo
sudo cp ambari.repo /etc/yum.repos.d
sudo rm -f ambari.repo
sudo yum install -y ambari-agent

# Format and mount the disks
let i=0 || true
for disk in $(sfdisk -l | grep "Disk /dev/sd[^ab]" | sed -r "s/Disk (\/dev\/sd.):.*$/\1/");
do
  sh ./mountDisk.sh $disk $i 0</dev/null & 
  let i=(i + 1) || true
done
wait

# Format the node IPs and setup the node
let "MASTERNODES=NAMENODES+1"

MASTER_NODES=()
for i in $(seq 1 $MASTERNODES)
do 
  let "IP=i+8"
  MASTER_NODES+=("$IPPREFIX$IP")
done
IFS=',';MASTER_NODE_IPS="${MASTER_NODES[*]}";IFS=$' \t\n'

WORKER_NODES=()
for i in $(seq 1 $DATANODES)
do 
  let "IP=i+19"
  WORKER_NODES+=("$IPPREFIX$IP")
done
IFS=',';WORKER_NODE_IPS="${WORKER_NODES[*]}";IFS=$' \t\n'

sudo python vm-bootstrap.py --action 'bootstrap' --cluster_id $NAMEPREFIX --scenario_id 'evaluation' --num_masters $MASTERNODES --num_workers $DATANODES --master_prefix "$NAMEPREFIX-mn-" --worker_prefix "$NAMEPREFIX-wn-" --domain_name ".$NAMESUFFIX" --admin_password 'admin' --masters_iplist $MASTER_NODE_IPS --workers_iplist $WORKER_NODE_IPS --id_padding 1
