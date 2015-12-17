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

echo "initializing nodes..."
IPPREFIX=$1
NAMEPREFIX=$2
NAMESUFFIX=$3
MASTERNODES=$4
DATANODES=$5
ADMINUSER=$6
NODETYPE=$7

# Converts a domain like machine.domain.com to domain.com by removing the machine name
NAMESUFFIX=`echo $NAMESUFFIX | sed 's/^[^.]*\.//'`

#Generate IP Addresses for the cloudera setup
NODES=()

let "NAMEEND=MASTERNODES-1"
for i in $(seq 0 $NAMEEND)
do 
  let "IP=i+10"
  NODES+=("$IPPREFIX$IP:${NAMEPREFIX}-mn$i.$NAMESUFFIX:${NAMEPREFIX}-mn$i")
done

let "DATAEND=DATANODES-1"
for i in $(seq 0 $DATAEND)
do 
  let "IP=i+20"
  NODES+=("$IPPREFIX$IP:${NAMEPREFIX}-dn$i.$NAMESUFFIX:${NAMEPREFIX}-dn$i")
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

# Disable the need for a tty when running sudo and allow passwordless sudo for the admin user
sed -i '/Defaults[[:space:]]\+!*requiretty/s/^/#/' /etc/sudoers
echo "$ADMINUSER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Mount and format the attached disks base on node type
if [ "$NODETYPE" == "masternode" ]
then
  bash ./prepare-masternode-disks.sh
elif [ "$NODETYPE" == "datanode" ]
then
  bash ./prepare-datanode-disks.sh
else
  echo "#unknown type, default to datanode"
  bash ./prepare-datanode-disks.sh
fi

echo "Done preparing disks.  Now ls -la looks like this:"
ls -la /
# Create Impala scratch directory
numDataDirs=$(ls -la / | grep data | wc -l)
echo "numDataDirs:" $numDataDirs
let endLoopIter=(numDataDirs - 1)
for x in $(seq 0 $endLoopIter)
do 
  echo mkdir -p /data${x}/impala/scratch 
  mkdir -p /data${x}/impala/scratch
  chmod 777 /data${x}/impala/scratch
done

setenforce 0 >> /tmp/setenforce.out
cat /etc/selinux/config > /tmp/beforeSelinux.out
sed -i 's^SELINUX=enforcing^SELINUX=disabled^g' /etc/selinux/config || true
cat /etc/selinux/config > /tmp/afterSeLinux.out

/etc/init.d/iptables save
/etc/init.d/iptables stop
chkconfig iptables off

yum install -y ntp
service ntpd start
service ntpd status
chkconfig ntpd on

yum install -y microsoft-hyper-v

echo never | tee -a /sys/kernel/mm/transparent_hugepage/enabled
echo "echo never | tee -a /sys/kernel/mm/transparent_hugepage/enabled" | tee -a /etc/rc.local
echo vm.swappiness=1 | tee -a /etc/sysctl.conf
echo 1 | tee /proc/sys/vm/swappiness
ifconfig -a >> initialIfconfig.out; who -b >> initialRestart.out

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

#use the key from the key vault as the SSH authorized key
mkdir /home/$ADMINUSER/.ssh
chown $ADMINUSER /home/$ADMINUSER/.ssh
chmod 700 /home/$ADMINUSER/.ssh

ssh-keygen -y -f /var/lib/waagent/*.prv > /home/$ADMINUSER/.ssh/authorized_keys
chown $ADMINUSER /home/$ADMINUSER/.ssh/authorized_keys
chmod 600 /home/$ADMINUSER/.ssh/authorized_keys

myhostname=`hostname`
fqdnstring=`python -c "import socket; print socket.getfqdn('$myhostname')"`
sed -i "s/.*HOSTNAME.*/HOSTNAME=${fqdnstring}/g" /etc/sysconfig/network
/etc/init.d/network restart

#disable password authentication in ssh
#sed -i "s/UsePAM\s*yes/UsePAM no/" /etc/ssh/sshd_config
#sed -i "s/PasswordAuthentication\s*yes/PasswordAuthentication no/" /etc/ssh/sshd_config
#/etc/init.d/sshd restart
