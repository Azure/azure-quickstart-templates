#!/bin/bash

### Cognosys Technologies
### 
### Warning! This script partitions and formats disk information be careful where you run it
###          This script is currently under development and has only been tested on Ubuntu images in Azure
###          This script is not currently idempotent and only works for provisioning at the moment

### Remaining work items
### -Alternate discovery options (Azure Storage)
### -Implement Idempotency and Configuration Change Support
### -Implement OS Disk Striping Option (Currenlty using multiple spark data paths)
### -Implement Non-Durable Option (Put data on resource disk)
### -Configure Work/Log Paths
### -Recovery Settings (These can be changed via API)


help()
{
    #TODO: Add help text here
    echo "This script installs spark cluster on Ubuntu"
    echo "Parameters:"
    echo "-k spark version like 1.2.1"
    echo "-m master 1 slave 0"
    echo "-h view this help content"
}

log()
{
	# If you want to enable this logging add a un-comment the line below and add your account key 
    	#curl -X POST -H "content-type:text/plain" --data-binary "$(date) | ${HOSTNAME} | $1" https://logs-01.loggly.com/inputs/[account-key]/tag/redis-extension,${HOSTNAME}
	echo "$1"
}

echo "Begin execution of spark script extension on ${HOSTNAME}"

if [ "${UID}" -ne 0 ];
then
    echo "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

#Script Parameters
SPK_VERSION="1.2.1"
MASTER1SLAVE0="-1"

#Loop through options passed
while getopts :k:m:h optname; do
    echo "Option $optname set with value ${OPTARG}"
  case $optname in
    k)  #spark version
      SPK_VERSION=${OPTARG}
      ;;
    m)  #Master 1 Slave 0
      MASTER1SLAVE0=${OPTARG}
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

#cd /usr/local/spark/conf
#echo "sparknode0" >> slaves
#echo "sparknode1" >> slaves

cd /usr/local/spark/sbin

if [ ${MASTER1SLAVE0} -eq "1" ];
then
	#
	#Start Master
	#-----------------------
	./start-master.sh
else
	#
	#Start Slave
	#-----------------------
	./start-slave.sh
fi

#========================= END ==================================

