#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This script will obtain the Solace message broker's docker image from
# sources and installs and runs it in a docker container
# solace_uri specifies where to get the docker image from
# - default (not specified): PubSub+ Standard from docker hub
# - Other public docker registry URI
# - solace.com/download
# - specified location of a docker image tarball URL
#



OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
current_index=""
dns_prefix=""
number_of_instances=""
solace_directory="/tmp"
solace_uri="solace/solace-pubsub-standard:latest"   # default to pull latest PubSub+ standard from docker hub
admin_password_file=""
disk_size=""
workspace_id=""
is_primary="false"

verbose=0

while getopts "c:d:n:p:s:w:u:" opt; do
  case "$opt" in
  c)  current_index=$OPTARG
    ;;
  d)  dns_prefix=$OPTARG
    ;;
  n)  number_of_instances=$OPTARG
    ;;
  p)  admin_password_file=$OPTARG
    ;;
  s)  disk_size=$OPTARG
    ;;
  u)  solace_uri=$OPTARG
    ;;
  w)  workspace_id=$OPTARG
    ;;
  esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

verbose=1
echo "`date` current_index=$current_index , dns_prefix=$dns_prefix , number_of_instances=$number_of_instances , \
      password_file=$admin_password_file , disk_size=$disk_size , workspace_id=$workspace_id , solace_uri=$solace_uri , \
      Leftovers: $@"
export admin_password=`cat ${admin_password_file}`

# Create working dir if needed
mkdir -p ${solace_directory}

#Install the logical volume manager and jq for json parsing
yum -y install lvm2
yum -y install epel-release
yum -y install jq

echo "`date` INFO: RETRIEVE SOLACE DOCKER IMAGE"
echo "###############################################################"
# Determine first if solace_uri is a valid docker registry uri
## First make sure Docker is actually up
docker_running=""
loop_guard=10
loop_count=0
while [ ${loop_count} != ${loop_guard} ]; do
  docker_running=`service docker status | grep -o running`
  if [ ${docker_running} != "running" ]; then
    ((loop_count++))
    echo "`date` WARN: Tried to launch Solace but Docker in state ${docker_running}"
    sleep 5
  else
    echo "`date` INFO: Docker in state ${docker_running}"
    break
  fi
done
## Remove any existing solace image
if [ "`docker images | grep solace-`" ] ; then
  echo "`date` INFO: Removing existing Solace images from local docker repo"
  docker rmi -f `docker images | grep solace- | awk '{print $3}'`
fi
## Try to load solace_uri as a docker registry uri
echo "`date` Testing ${solace_uri} for docker registry uri:"
if [ -z "`docker pull ${solace_uri}`" ] ; then
  # If NOT in this branch then load was successful
  echo "`date` INFO: Found that ${solace_uri} was not a docker registry uri, retrying if it is a download link"
  if [[ ${solace_uri} == *"solace.com/download"* ]]; then
    REAL_LINK=${solace_uri}
    # the new download url
    wget -O ${solace_directory}/solos.info -nv  ${solace_uri}_MD5
  else
    REAL_LINK=${solace_uri}
    # an already-existing load (plus its md5 file) hosted somewhere else (e.g. in an s3 bucket)
    wget -O ${solace_directory}/solos.info -nv  ${solace_uri}.md5
  fi
  IFS=' ' read -ra SOLOS_INFO <<< `cat ${solace_directory}/solos.info`
  MD5_SUM=${SOLOS_INFO[0]}
  SolOS_LOAD=${SOLOS_INFO[1]}
  if [ -z ${MD5_SUM} ]; then
    echo "`date` ERROR: Missing md5sum for the Solace load - exiting." | tee /dev/stderr
    exit 1
  fi
  echo "`date` INFO: Reference md5sum is: ${MD5_SUM}"

  echo "`date` INFO: Now download from URL provided and validate, trying up to 5 times"
  LOOP_COUNT=0
  while [ $LOOP_COUNT -lt 5 ]; do
    wget -q -O  ${solace_directory}/${SolOS_LOAD} ${REAL_LINK} || echo "There has been an issue with downloading the Solace load"
    ## Check MD5
    LOCAL_OS_INFO=`md5sum ${solace_directory}/${SolOS_LOAD}`
    IFS=' ' read -ra SOLOS_INFO <<< ${LOCAL_OS_INFO}
    LOCAL_MD5_SUM=${SOLOS_INFO[0]}
    if [ -z "${MD5_SUM}" ] || [ "${LOCAL_MD5_SUM}" != "${MD5_SUM}" ]; then
      echo "`date` WARN: Possible corrupt Solace load, md5sum do not match"
    else
      echo "`date` INFO: Successfully downloaded ${SolOS_LOAD}"
      break
    fi
    ((LOOP_COUNT++))
  done
  if [ ${LOOP_COUNT} == 3 ]; then
    echo "`date` ERROR: Failed to download the Solace load, exiting" | tee /dev/stderr
    exit 1
  fi
  ## Load the image tarball
  docker load -i ${solace_directory}/${SolOS_LOAD}
fi
## Image details
export SOLACE_IMAGE_ID=`docker images | grep solace | awk '{print $3}'`
if [ -z "${SOLACE_IMAGE_ID}" ] ; then
  echo "`date` ERROR: Could not load a valid Solace docker image - exiting." | tee /dev/stderr
  exit 1
fi
echo "`date` INFO: Successfully loaded ${solace_uri} to local docker repo"
echo "`date` INFO: Solace message broker image and tag: `docker images | grep solace | awk '{print $1,":",$2}'`"

# Decide which scaling tier applies based on system memory
# and set maxconnectioncount, ulimit, devshm and swap accordingly
MEM_SIZE=`cat /proc/meminfo | grep MemTotal | tr -dc '0-9'`
if [ ${MEM_SIZE} -lt 4000000 ]; then
  # 100 if mem<4GiB
  maxconnectioncount="100"
  shmsize="1g"
  ulimit_nofile="2448:6592"
  SWAP_SIZE="1024"
elif [ ${MEM_SIZE} -lt 12000000 ]; then
  # 1000 if 4GiB<=mem<12GiB
  maxconnectioncount="1000"
  shmsize="2g"
  ulimit_nofile="2448:10192"
  SWAP_SIZE="2048"
elif [ ${MEM_SIZE} -lt 29000000 ]; then
  # 10000 if 12GiB<=mem<28GiB
  maxconnectioncount="10000"
  shmsize="2g"
  ulimit_nofile="2448:42192"
  SWAP_SIZE="2048"
elif [ ${MEM_SIZE} -lt 58000000 ]; then
  # 100000 if 28GiB<=mem<56GiB
  maxconnectioncount="100000"
  shmsize="3380m"
  ulimit_nofile="2448:222192"
  SWAP_SIZE="2048"
else
  # 200000 if 56GiB<=mem
  maxconnectioncount="200000"
  shmsize="3380m"
  ulimit_nofile="2448:422192"
  SWAP_SIZE="2048"
fi
echo "`date` INFO: Based on memory size of ${MEM_SIZE}KiB, determined maxconnectioncount: ${maxconnectioncount}, shmsize: ${shmsize}, ulimit_nofile: ${ulimit_nofile}, SWAP_SIZE: ${SWAP_SIZE}"

echo "`date` INFO: Creating Swap space"
mkdir /var/lib/solace
dd if=/dev/zero of=/var/lib/solace/swap count=${SWAP_SIZE} bs=1MiB
mkswap -f /var/lib/solace/swap
chmod 0600 /var/lib/solace/swap
swapon -f /var/lib/solace/swap
grep -q 'solace\/swap' /etc/fstab || sudo sh -c 'echo "/var/lib/solace/swap none swap sw 0 0" >> /etc/fstab'

if [ ${number_of_instances} -gt 1 ]; then
  echo "`date` INFO: Configuring HA tuple"
  case ${current_index} in
    0 )
      redundancy_config="\
      --env nodetype=message_routing \
      --env routername=${dns_prefix}primary \
      --env redundancy_activestandbyrole=primary \
      --env redundancy_matelink_connectvia=${dns_prefix}1 \
      --env redundancy_group_passwordfilepath=$(basename ${admin_password_file}) \
      --env redundancy_enable=yes \
      --env redundancy_group_node_${dns_prefix}primary_nodetype=message_routing \
      --env redundancy_group_node_${dns_prefix}primary_connectvia=${dns_prefix}0 \
      --env redundancy_group_node_${dns_prefix}backup_nodetype=message_routing \
      --env redundancy_group_node_${dns_prefix}backup_connectvia=${dns_prefix}1 \
      --env redundancy_group_node_${dns_prefix}monitor_nodetype=monitoring \
      --env redundancy_group_node_${dns_prefix}monitor_connectvia=${dns_prefix}2 \
      --env configsync_enable=yes"
      is_primary="true"
        ;;
    1 )
      redundancy_config="\
      --env nodetype=message_routing \
      --env routername=${dns_prefix}backup \
      --env redundancy_matelink_connectvia=${dns_prefix}0 \
      --env redundancy_activestandbyrole=backup \
      --env redundancy_group_passwordfilepath=$(basename ${admin_password_file}) \
      --env redundancy_enable=yes \
      --env redundancy_group_node_${dns_prefix}primary_nodetype=message_routing \
      --env redundancy_group_node_${dns_prefix}primary_connectvia=${dns_prefix}0 \
      --env redundancy_group_node_${dns_prefix}backup_nodetype=message_routing \
      --env redundancy_group_node_${dns_prefix}backup_connectvia=${dns_prefix}1 \
      --env redundancy_group_node_${dns_prefix}monitor_nodetype=monitoring \
      --env redundancy_group_node_${dns_prefix}monitor_connectvia=${dns_prefix}2 \
      --env configsync_enable=yes"
        ;;
    2 )
      redundancy_config="\
      --env nodetype=monitoring \
      --env routername=${dns_prefix}monitor \
      --env redundancy_group_passwordfilepath=$(basename ${admin_password_file}) \
      --env redundancy_enable=yes \
      --env redundancy_group_node_${dns_prefix}primary_nodetype=message_routing \
      --env redundancy_group_node_${dns_prefix}primary_connectvia=${dns_prefix}0 \
      --env redundancy_group_node_${dns_prefix}backup_nodetype=message_routing \
      --env redundancy_group_node_${dns_prefix}backup_connectvia=${dns_prefix}1 \
      --env redundancy_group_node_${dns_prefix}monitor_nodetype=monitoring \
      --env redundancy_group_node_${dns_prefix}monitor_connectvia=${dns_prefix}2"
        ;;
  esac
else
  echo "`date` INFO: Configuring singleton"
  redundancy_config=""
fi

#Create new volumes that the PubSub+ Message Broker container can use to consume and store data.
docker volume create --name=jail
docker volume create --name=var
docker volume create --name=softAdb
docker volume create --name=adbBackup

if [ ${disk_size} == "0" ]; then
  docker volume create --name=diagnostics
  docker volume create --name=internalSpool
  SPOOL_MOUNT="-v diagnostics:/var/lib/solace/diags -v internalSpool:/usr/sw/internalSpool"
else
  # Look for unpartitioned disks
  disk_volume=""
  DEVS=($(ls -1 /dev/sd*|egrep -v "[0-9]$"))
  for DEV in "${DEVS[@]}"; do
    # Check each device if there is a "1" partition.
    # If not, assume it is not partitioned.
    if [ ! -b ${DEV}1 ]; then
      echo "`date` INFO: Disk device with no primary partition found"
      disk_volume="${DEV}"
      break
    fi
  done
  if [ ${disk_volume} == "" ]; then
    echo "`date` INFO: Default disk device to /dev/sdc"
    disk_volume="/dev/sdc"
  fi
  echo "`date` INFO: Create primary partition on disk device ${disk_volume} of size ${disk_size} GiB"
  (
    echo n # Add a new partition
    echo p # Primary partition
    echo 1  # Partition number
    echo   # First sector (Accept default: 1)
    echo   # Last sector (Accept default: varies)
    echo w # Write changes
  ) | sudo fdisk $workspace_id
  mkfs.xfs  ${workspace_id}1 -m crc=0
  UUID=`blkid -s UUID -o value ${workspace_id}1`
  echo "UUID=${UUID} /opt/vmr xfs defaults 0 0" >> /etc/fstab
  mkdir /opt/vmr
  mkdir /opt/vmr/diagnostics
  mkdir /opt/vmr/internalSpool
  mount -a
  SPOOL_MOUNT="-v /opt/vmr/diagnostics:/var/lib/solace/diags -v /opt/vmr/internalSpool:/usr/sw/internalSpool"
fi

LOG_OPT=""
logging_config=""
if [[ ${workspace_id} != "" ]]; then
  SYSLOG_CONF="/etc/opt/microsoft/omsagent/${workspace_id}/conf/omsagent.d/syslog.conf"
  SYSLOG_PORT=""
  if [ -f ${SYSLOG_CONF} ]; then
    echo "`date` INFO: Configuration file for syslog found"
    SYSLOG_PORT=$(sed -n 's/.*port \(.*\).*/\1/p' $SYSLOG_CONF)
  fi
  if [[ ${SYSLOG_PORT} == "" ]]; then
    echo "`date` INFO: Default syslog port to 25224"
    SYSLOG_PORT="25224"
  fi
  echo "`date` INFO: Configuring logging on syslog port ${SYSLOG_PORT}"
  LOG_OPT="--log-driver syslog --log-opt syslog-format=rfc3164 --log-opt syslog-address=udp://127.0.0.1:$SYSLOG_PORT"
  logging_config="\
    --env logging_debug_output=all \
    --env logging_debug_format=graylog \
    --env logging_command_output=all \
    --env logging_command_format=graylog \
    --env logging_system_output=all \
    --env logging_system_format=graylog \
    --env logging_event_output=all \
    --env logging_event_format=graylog \
    --env logging_kernel_output=all \
    --env logging_kernel_format=graylog"
fi

#Define a create script
tee /root/docker-create <<-EOF
#!/bin/bash
docker create \
 --privileged=true \
 --net=host \
 --uts=host \
 --shm-size=${shmsize} \
 --ulimit core=-1 \
 --ulimit memlock=-1 \
 --ulimit nofile=${ulimit_nofile} \
 ${LOG_OPT} \
 -v $(dirname ${admin_password_file}):/run/secrets \
 -v jail:/usr/sw/jail \
 -v var:/usr/sw/var \
 -v softAdb:/usr/sw/internalSpool/softAdb \
 -v adbBackup:/usr/sw/adb \
 ${SPOOL_MOUNT} \
 --env username_admin_globalaccesslevel=admin \
 --env username_admin_passwordfilepath=$(basename ${admin_password_file}) \
 --env system_scaling_maxconnectioncount=${maxconnectioncount} \
 ${logging_config} \
 ${redundancy_config} \
 --name=solace ${SOLACE_IMAGE_ID}
EOF

#Make the file executable
chmod +x /root/docker-create

echo "`date` INFO: Creating the Solace container"
/root/docker-create

#Construct systemd for PubSub+ Message Broker
tee /etc/systemd/system/solace-pubsubplus.service <<-EOF
[Unit]
  Description=solace-pubsubplus
  Requires=docker.service
  After=docker.service
[Service]
  Restart=always
  ExecStart=/usr/bin/docker start -a solace
  ExecStop=/usr/bin/docker stop solace
[Install]
  WantedBy=default.target
EOF

echo "`date` INFO: Start the Solace PubSub+ Message Broker container"
systemctl daemon-reload
systemctl enable solace-pubsubplus
systemctl start solace-pubsubplus

# Poll the PubSub+ Message Broker SEMP port until it is Up
loop_guard=30
pause=10
count=0
echo "`date` INFO: Wait for the Solace SEMP service to be enabled"
while [ ${count} -lt ${loop_guard} ]; do
  online_results=`./semp_query.sh -n admin -p ${admin_password} -u http://localhost:8080/SEMP \
    -q "<rpc><show><service/></show></rpc>" \
    -v "/rpc-reply/rpc/show/service/services/service[name='SEMP']/enabled[text()]"`

  is_messagebroker_up=`echo ${online_results} | jq '.valueSearchResult' -`
  echo "`date` INFO: SEMP service 'enabled' status is: ${is_messagebroker_up}"

  run_time=$((${count} * ${pause}))
  if [ "${is_messagebroker_up}" = "\"true\"" ]; then
    echo "`date` INFO: Solace message broker SEMP service is up, after ${run_time} seconds"
    break
  fi
  ((count++))
  echo "`date` INFO: Waited ${run_time} seconds, Solace message broker SEMP service not yet up"
  sleep ${pause}
done

# Remove all VMR Secrets from the host; at this point, the VMR should have come up
# and it won't be needing those files anymore
rm ${admin_password_file}

# Poll the redundancy status on the Primary VMR
if [ "${is_primary}" = "true" ]; then
  loop_guard=30
  pause=10
  count=0
  mate_active_check=""
  echo "`date` INFO: Wait for Primary to be 'Local Active' or 'Mate Active'"
  while [ ${count} -lt ${loop_guard} ]; do
    online_results=`./semp_query.sh -n admin -p ${admin_password} -u http://localhost:8080/SEMP \
         -q "<rpc><show><redundancy><detail/></redundancy></show></rpc>" \
         -v "/rpc-reply/rpc/show/redundancy/virtual-routers/primary/status/activity[text()]"`

    local_activity=`echo ${online_results} | jq '.valueSearchResult' -`
    echo "`date` INFO: Local activity state is: ${local_activity}"

    run_time=$((${count} * ${pause}))
    case "${local_activity}" in
      "\"Local Active\"")
        echo "`date` INFO: Redundancy is up locally, Primary Active, after ${run_time} seconds"
        mate_active_check="Standby"
        break
        ;;
      "\"Mate Active\"")
        echo "`date` INFO: Redundancy is up locally, Backup Active, after ${run_time} seconds"
        mate_active_check="Active"
        break
        ;;
    esac
    ((count++))
    echo "`date` INFO: Waited ${run_time} seconds, Redundancy not yet up"
    sleep ${pause}
  done

  if [ ${count} -eq ${loop_guard} ]; then
    echo "`date` ERROR: Solace redundancy group never came up" | tee /dev/stderr
    echo "`date` ERROR: giving up! Details:"
    echo `curl -u admin:${admin_password} http://localhost:8080/SEMP -d "<rpc><show><redundancy><detail/></redundancy></show></rpc>"`
    exit 1
  fi

  loop_guard=45
  pause=10
  count=0
  echo "`date` INFO: Wait for Backup to be 'Active' or 'Standby'"
  while [ ${count} -lt ${loop_guard} ]; do
    online_results=`./semp_query.sh -n admin -p ${admin_password} -u http://localhost:8080/SEMP \
         -q "<rpc><show><redundancy><detail/></redundancy></show></rpc>" \
         -v "/rpc-reply/rpc/show/redundancy/virtual-routers/primary/status/detail/priority-reported-by-mate/summary[text()]"`

    mate_activity=`echo ${online_results} | jq '.valueSearchResult' -`
    echo "`date` INFO: Mate activity state is: ${mate_activity}"

    run_time=$((${count} * ${pause}))
    case "${mate_activity}" in
      "\"Active\"")
        echo "`date` INFO: Redundancy is up end-to-end, Backup Active, after ${run_time} seconds"
        mate_active_check="Standby"
        break
        ;;
      "\"Standby\"")
        echo "`date` INFO: Redundancy is up end-to-end, Primary Active, after ${run_time} seconds"
        mate_active_check="Active"
        break
        ;;
    esac
    ((count++))
    echo "`date` INFO: Waited ${run_time} seconds, Backup not yet 'Active' or 'Standby'"
    sleep ${pause}
  done

  if [ ${count} -eq ${loop_guard} ]; then
    echo "`date` ERROR: Backup never became 'Active' or 'Standby'" | tee /dev/stderr
    echo "`date` ERROR: giving up! Details:"
    echo `curl -u admin:${admin_password} http://localhost:8080/SEMP -d "<rpc><show><redundancy><detail/></redundancy></show></rpc>"`
    exit 1
  fi

 ./semp_query.sh -n admin -p ${admin_password} -u http://localhost:8080/SEMP \
         -q "<rpc><admin><config-sync><assert-master><router/></assert-master></config-sync></admin></rpc>"
 ./semp_query.sh -n admin -p ${admin_password} -u http://localhost:8080/SEMP \
         -q "<rpc><admin><config-sync><assert-master><vpn-name>default</vpn-name></assert-master></config-sync></admin></rpc>"
fi

if [ ${count} -eq ${loop_guard} ]; then
  echo "`date` ERROR: Solace bringup failed" | tee /dev/stderr
  exit 1
fi
echo "`date` INFO: Solace bringup complete"
