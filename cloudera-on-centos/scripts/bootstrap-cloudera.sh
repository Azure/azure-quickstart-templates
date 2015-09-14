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
# Usage: bootstrap-cloudera-1.0.sh {clusterName} {managment_node} {cluster_nodes} {isHA} {sshUserName} [{sshPassword}]

# Put the command line parameters into named variables
IPPREFIX=$1
NAMEPREFIX=$2
NAMESUFFIX=$3
MASTERNODES=$4
DATANODES=$5
ADMINUSER=$6
HA=$7
PASSWORD=$8
CMUSER=$9
CMPASSWORD=${10}
EMAILADDRESS=${11}
BUSINESSPHONE=${12}
FIRSTNAME=${13}
LASTNAME=${14}
JOBROLE=${15}
JOBFUNCTION=${16}
COMPANY=${17}

CLUSTERNAME=$NAMEPREFIX

execname=$0

log() {
  echo "$(date): [${execname}] $@" 
}

# Converts a domain like machine.domain.com to domain.com by removing the machine name
NAMESUFFIX=`echo $NAMESUFFIX | sed 's/^[^.]*\.//'`

ManagementNode="${IPPREFIX}10:${NAMEPREFIX}-mn0.$NAMESUFFIX:${NAMEPREFIX}-mn0"
mip=$(echo "$ManagementNode" | sed 's/:/ /' | sed 's/:/ /' | cut -d ' ' -f 1)

log "set private key"
#use the key from the key vault as the SSH private key
openssl rsa -in /var/lib/waagent/*.prv -out /home/$ADMINUSER/.ssh/id_rsa
chmod 600 /home/$ADMINUSER/.ssh/id_rsa
chown $ADMINUSER /home/$ADMINUSER/.ssh/id_rsa

file="/home/$ADMINUSER/.ssh/id_rsa"
key="/tmp/id_rsa.pem"
openssl rsa -in $file -outform PEM > $key

#Generate IP Addresses for the cloudera setup
NODES=()

let "NAMEEND=MASTERNODES-1"
for i in $(seq 1 $NAMEEND)
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

IFS=',';NODE_IPS="${NODES[*]}";IFS=$' \t\n'

wip_string=''
OIFS=$IFS
IFS=','
for x in $NODE_IPS
do
  log "Workier IP: $x"
  line=$(echo "$x" | sed 's/:/ /' | sed 's/:/ /')
  wip_string+=$(echo "$line" | cut -d ' ' -f 1 | sed 's/$/,/')
  log "current wip_string is: $wip_string"
done
IFS=${OIFS}
worker_ip=$(echo "${wip_string%?}")
log "Worker ip to be supplied to next script: $worker_ip"
log "Adminuser: $ADMINUSER Adminpassword: $PASSWORD"
log "BEGIN: Starting detached script to finalize initialization"
log "CMUSER $CMUSER, CMPASSWORD $CMPASSWORD, ${10}"
sh initialize-cloudera-server.sh "$CLUSTERNAME" "$key" "$mip" "$worker_ip" $HA $ADMINUSER $PASSWORD $CMUSER $CMPASSWORD $EMAILADDRESS $BUSINESSPHONE $FIRSTNAME $LASTNAME $JOBROLE $JOBFUNCTION $COMPANY>/dev/null 2>&1
log "END: Detached script to finalize initialization running. PID: $!"

