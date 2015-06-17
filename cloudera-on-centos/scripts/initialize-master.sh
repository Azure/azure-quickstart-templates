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

# Put the command line parameters into named variables
IPPREFIX=$1
NAMEPREFIX=$2
NAMESUFFIX=$3
NAMENODES=$4
DATANODES=$5
ADMINUSER=$6

sh ./initialize-node.sh $ADMINUSER

# Converts a domain like machine.domain.com to domain.com by removing the machine name
NAMESUFFIX=`echo $NAMESUFFIX | sed 's/^[^.]*\.//'`

#use the key from the key vault as the SSH private key
openssl rsa -in /var/lib/waagent/*.prv -out /home/$ADMINUSER/.ssh/id_rsa
chmod 600 /home/$ADMINUSER/.ssh/id_rsa
chown $ADMINUSER /home/$ADMINUSER/.ssh/id_rsa

#Generate IP Addresses for the cloudera setup
NODES=()

let "NAMEEND=NAMENODES-1"
for i in $(seq 0 $NAMEEND)
do 
  let "IP=i+10"
  NODES+=("$IPPREFIX$IP:${NAMEPREFIX}-nn$i.$NAMESUFFIX:${NAMEPREFIX}-nn$i")
done

let "DATAEND=DATANODES-1"
for i in $(seq 0 $DATAEND)
do 
  let "IP=i+20"
  NODES+=("$IPPREFIX$IP:${NAMEPREFIX}-dn$i.$NAMESUFFIX:${NAMEPREFIX}-dn$i")
done

IFS=',';NODE_IPS="${NODES[*]}";IFS=$' \t\n'

echo "$(date): calling bootstrap_cloudera"
sh bootstrap-cloudera.sh 'cloudera' "${IPPREFIX}9:${NAMEPREFIX}-mn.$NAMESUFFIX:${NAMEPREFIX}-mn" $NODE_IPS false $ADMINUSER >> /home/$ADMINUSER/bootstrap-cloudera.log 2>&1
echo "$(date): done bootstrap_cloudera"
