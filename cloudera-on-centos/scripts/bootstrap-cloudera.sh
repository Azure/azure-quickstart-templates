#!/usr/bin/env bash
# Usage: bootstrap-cloudera-1.0.sh {clusterName} {managment_node} {cluster_nodes} {isHA} {sshUserName} [{sshPassword}]

execname=$0

log() {
  echo "[${execname}] $@" 
}

log "BEGIN: Processing text stream from Azure ARM call"

ClusterName=$1 
ManagementNode=$2
ClusterNodes=$3
HA=$4
User=$5
Password=$6

log "set private key"
file="/home/$User/.ssh/id_rsa"
key="/tmp/id_rsa.pem"
openssl rsa -in $file -outform PEM > $key

log "remove requiretty"
sed -i 's^requiretty^!requiretty^g' /etc/sudoers
log "done removing requiretty"

log "cm ip fix"
#CM IP fix. Strips back ticks and creates the format getting the IP address.
CM_IP=$(echo $ManagementNode | sed 's/:/ /' | sed 's/:/ /') 
echo "$CM_IP" >> /etc/hosts

OIFS=$IFS
IFS=':'
mip=''
for x in $CM_IP
do
  mip=$(echo "$x" | sed 's/:/ /' | sed 's/:/ /' | cut -d ' ' -f 1)
  log "CM IP: $mip" 	
done
IFS=OIFS

log "Cluster Name: $ClusterName and User Name: $User"

log "worker name fix"
#Worker string fix. Strips back ticks and creates the format for /etc/hosts file
Worker_IP=$ClusterNodes 
log $Worker_IP

#echo $Worker_IP
wip_string=''
OIFS=$IFS
IFS=','
for x in $Worker_IP
do
  log "Workier IP: $x"
  line=$(echo "$x" | sed 's/:/ /' | sed 's/:/ /')
  log "New Worker IP to be added to /etc/hosts: $line"
  echo "$line" >> /etc/hosts
  wip_string+=$(echo "$line" | cut -d ' ' -f 1 | sed 's/$/,/')
  log "current wip_string is: $wip_string"
done
IFS=OIFS
worker_ip=$(echo "${wip_string%?}")
log "Worker ip to be supplied to next script: $worker_ip"

log "BEGIN: Copy hosts file to all nodes"

OIFS=$IFS
IFS=','

for node in $ClusterNodes
do
  remote=$(echo "$node" | sed 's/:/ /' | sed 's/:/ /' | cut -d ' ' -f 1)
  log "Copy hosts file to: $remote"
  n=0
  until [ $n -ge 5 ]
  do
      scp -o StrictHostKeyChecking=no -i /home/$User/.ssh/id_rsa /etc/hosts $User@$remote:/tmp/hosts && break
      n=$[$n+1]
      sleep 15
  done
  if [ $n -ge 5 ]; then log "scp error $remote, exiting..." & exit 1; fi
  ssh -o StrictHostKeyChecking=no -i /home/$User/.ssh/id_rsa -t -t $User@$remote << EOF
      sudo cp /tmp/hosts /etc/hosts 
      sudo bash -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'
      echo vm.swappiness=1 | sudo tee -a /etc/systctl.conf; sudo echo 1 | sudo tee /proc/sys/vm/swappiness
      sudo ifconfig -a >> initialIfconfig.out; who -b >> initialRestart.out
      exit 0
EOF
  if [ $? -ne 0 ]; then log "ssh 4 error $remote, exiting..." & exit 1; fi
done

IFS=$OIFS

log "BEGIN: Starting detached script to finalize initialization"
sh initialize-cloudera-server.sh "$ClusterName" "$key" "$mip" "$worker_ip" $HA $User $Password >/dev/null 2>&1
log "END: Detached script to finalize initialization running. PID: $!"

