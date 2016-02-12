#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2015 Microsoft Azure
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#--------------------------------------------------------------------------------------------------
# MongoDB Template for Azure Resource Manager (brought to you by Full Scale 180 Inc)
#
# This script installs MongoDB on each Azure virtual machine. The script will be supplied with
# runtime parameters declared from within the corresponding ARM template.
#--------------------------------------------------------------------------------------------------

PACKAGE_URL=http://repo.mongodb.org/apt/ubuntu
PACKAGE_NAME=mongodb-org
REPLICA_SET_KEY_DATA=""
REPLICA_SET_NAME=""
REPLICA_SET_KEY_FILE="/etc/mongo-replicaset-key"
DATA_DISKS="/datadisks"
DATA_MOUNTPOINT="$DATA_DISKS/disk1"
MONGODB_DATA="$DATA_MOUNTPOINT/mongodb"
MONGODB_PORT=27017
IS_ARBITER=false
IS_LAST_MEMBER=false
JOURNAL_ENABLED=true
ADMIN_USER_NAME=""
ADMIN_USER_PASSWORD=""
INSTANCE_COUNT=1
NODE_IP_PREFIX="10.0.0.1"
LOGGING_KEY="[logging-key]"

help()
{
	echo "This script installs MongoDB on the Ubuntu virtual machine image"
	echo "Options:"
	echo "		-i Installation package URL"
	echo "		-b Installation package name"
	echo "		-r Replica set name"
	echo "		-k Replica set key"
	echo "		-u System administrator's user name"
	echo "		-p System administrator's password"
	echo "		-x Member node IP prefix"	
	echo "		-n Number of member nodes"	
	echo "		-a (arbiter indicator)"	
	echo "		-l (last member indicator)"	
}

log()
{
	# If you want to enable this logging add a un-comment the line below and add your account key 
	#curl -X POST -H "content-type:text/plain" --data-binary "$(date) | ${HOSTNAME} | $1" https://logs-01.loggly.com/inputs/${LOGGING_KEY}/tag/redis-extension,${HOSTNAME}
	echo "$1"
}

log "Begin execution of MongoDB installation script extension on ${HOSTNAME}"

if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

# Parse script parameters
while getopts :i:b:r:k:u:p:x:n:alh optname; do

	# Log input parameters (except the admin password) to facilitate troubleshooting
	if [ ! "$optname" == "p" ] && [ ! "$optname" == "k" ]; then
		log "Option $optname set with value ${OPTARG}"
	fi
  
	case $optname in
	i) # Installation package location
		PACKAGE_URL=${OPTARG}
		;;
	b) # Installation package name
		PACKAGE_NAME=${OPTARG}
		;;
	r) # Replica set name
		REPLICA_SET_NAME=${OPTARG}
		;;	
	k) # Replica set key
		REPLICA_SET_KEY_DATA=${OPTARG}
		;;	
	u) # Administrator's user name
		ADMIN_USER_NAME=${OPTARG}
		;;		
	p) # Administrator's user name
		ADMIN_USER_PASSWORD=${OPTARG}
		;;	
	x) # Private IP address prefix
		NODE_IP_PREFIX=${OPTARG}
		;;				
	n) # Number of instances
		INSTANCE_COUNT=${OPTARG}
		;;		
	a) # Arbiter indicator
		IS_ARBITER=true
		JOURNAL_ENABLED=false
		;;		
	l) # Last member indicator
		IS_LAST_MEMBER=true
		;;		
    h)  # Helpful hints
		help
		exit 2
		;;
    \?) # Unrecognized option - show help
		echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
		help
		exit 2
		;;
  esac
done

# Validate parameters
if [ "$ADMIN_USER_NAME" == "" ] || [ "$ADMIN_USER_PASSWORD" == "" ];
then
    log "Script executed without admin credentials"
    echo "You must provide a name and password for the system administrator." >&2
    exit 3
fi

#############################################################################
tune_memory()
{
	# Disable THP on a running system
	echo never > /sys/kernel/mm/transparent_hugepage/enabled
	echo never > /sys/kernel/mm/transparent_hugepage/defrag

	# Disable THP upon reboot
	cp -p /etc/rc.local /etc/rc.local.`date +%Y%m%d-%H:%M`
	sed -i -e '$i \ if test -f /sys/kernel/mm/transparent_hugepage/enabled; then \
 			 echo never > /sys/kernel/mm/transparent_hugepage/enabled \
		  fi \ \
		if test -f /sys/kernel/mm/transparent_hugepage/defrag; then \
		   echo never > /sys/kernel/mm/transparent_hugepage/defrag \
		fi \
		\n' /etc/rc.local
}

tune_system()
{
	# Add local machine name to the hosts file to facilitate IP address resolution
	if grep -q "${HOSTNAME}" /etc/hosts
	then
	  echo "${HOSTNAME} was found in /etc/hosts"
	else
	  echo "${HOSTNAME} was not found in and will be added to /etc/hosts"
	  # Append it to the hsots file if not there
	  echo "127.0.0.1 $(hostname)" >> /etc/hosts
	  log "Hostname ${HOSTNAME} added to /etc/hosts"
	fi	
}

#############################################################################
install_mongodb()
{
	log "Downloading MongoDB package $PACKAGE_NAME from $PACKAGE_URL"

	# Configure mongodb.list file with the correct location
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
	echo "deb ${PACKAGE_URL} "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.0.list

	# Install updates
	apt-get -y update

	# Remove any previously created configuration file to avoid a prompt
	if [ -f /etc/mongod.conf ]; then
		rm /etc/mongod.conf
	fi
	
	#Install Mongo DB
	log "Installing MongoDB package $PACKAGE_NAME"
	apt-get -y install $PACKAGE_NAME
	
	# Stop Mongod as it may be auto-started during the above step (which is not desirable)
	stop_mongodb
}

#############################################################################
configure_datadisks()
{
	# Stripe all of the data 
	log "Formatting and configuring the data disks"
	
	bash ./vm-disk-utils-0.1.sh -b $DATA_DISKS -s
}

#############################################################################
configure_replicaset()
{
	log "Configuring a replica set $REPLICA_SET_NAME"
	
	echo "$REPLICA_SET_KEY_DATA" | tee "$REPLICA_SET_KEY_FILE" > /dev/null
	chown -R mongodb:mongodb "$REPLICA_SET_KEY_FILE"
	chmod 600 "$REPLICA_SET_KEY_FILE"
	
	# Enable replica set in the configuration file
	sed -i "s|#keyFile: \"\"$|keyFile: \"${REPLICA_SET_KEY_FILE}\"|g" /etc/mongod.conf
	sed -i "s|authorization: \"disabled\"$|authorization: \"enabled\"|g" /etc/mongod.conf
	sed -i "s|#replication:|replication:|g" /etc/mongod.conf
	sed -i "s|#replSetName:|replSetName:|g" /etc/mongod.conf
	
	# Stop the currently running MongoDB daemon as we will need to reload its configuration
	stop_mongodb
	
	# Attempt to start the MongoDB daemon so that configuration changes take effect
	start_mongodb
	
	# Initiate a replica set (only run this section on the very last node)
	if [ "$IS_LAST_MEMBER" = true ]; then
		# Log a message to facilitate troubleshooting
		log "Initiating a replica set $REPLICA_SET_NAME with $INSTANCE_COUNT members"
	
		# Initiate a replica set
		mongo master -u $ADMIN_USER_NAME -p $ADMIN_USER_PASSWORD --host 127.0.0.1 --eval "printjson(rs.initiate())"
		
		# Add all members except this node as it will be included into the replica set after the above command completes
		for (( n=0 ; n<($INSTANCE_COUNT-1) ; n++)) 
		do 
			MEMBER_HOST="${NODE_IP_PREFIX}${n}:${MONGODB_PORT}"
			
			log "Adding member $MEMBER_HOST to replica set $REPLICA_SET_NAME" 
			mongo master -u $ADMIN_USER_NAME -p $ADMIN_USER_PASSWORD --host 127.0.0.1 --eval "printjson(rs.add('${MEMBER_HOST}'))"
		done
		
		# Print the current replica set configuration
		mongo master -u $ADMIN_USER_NAME -p $ADMIN_USER_PASSWORD --host 127.0.0.1 --eval "printjson(rs.conf())"	
		mongo master -u $ADMIN_USER_NAME -p $ADMIN_USER_PASSWORD --host 127.0.0.1 --eval "printjson(rs.status())"	
	fi
	
	# Register an arbiter node with the replica set
	if [ "$IS_ARBITER" = true ]; then
	
		# Work out the IP address of the last member node where we initiated a replica set
		let "PRIMARY_MEMBER_INDEX=$INSTANCE_COUNT-1"
		PRIMARY_MEMBER_HOST="${NODE_IP_PREFIX}${PRIMARY_MEMBER_INDEX}:${MONGODB_PORT}"
		CURRENT_NODE_IPS=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
		CURRENT_NODE_IP=${CURRENT_NODE_IPS[@]}

		log "Adding an arbiter ${HOSTNAME} ($CURRENT_NODE_IP) node to the replica set $REPLICA_SET_NAME"
		mongo master -u $ADMIN_USER_NAME -p $ADMIN_USER_PASSWORD --host $PRIMARY_MEMBER_HOST --eval "printjson(rs.addArb('${CURRENT_NODE_IP}'))"
	fi
}

#############################################################################
configure_mongodb()
{
	log "Configuring MongoDB"

	mkdir -p "$MONGODB_DATA"
	mkdir "$MONGODB_DATA/log"
	mkdir "$MONGODB_DATA/db"
	
	chown -R mongodb:mongodb "$MONGODB_DATA/db"
	chown -R mongodb:mongodb "$MONGODB_DATA/log"
	chmod 755 "$MONGODB_DATA"
	
	mkdir /var/run/mongodb
	touch /var/run/mongodb/mongod.pid
	chmod 777 /var/run/mongodb/mongod.pid
	
	tee /etc/mongod.conf > /dev/null <<EOF
systemLog:
    destination: file
    path: "$MONGODB_DATA/log/mongod.log"
    quiet: true
    logAppend: true
processManagement:
    fork: true
    pidFilePath: "/var/run/mongodb/mongod.pid"
net:
    port: $MONGODB_PORT
security:
    #keyFile: ""
    authorization: "disabled"
storage:
    dbPath: "$MONGODB_DATA/db"
    directoryPerDB: true
    journal:
        enabled: $JOURNAL_ENABLED
#replication:
    #replSetName: "$REPLICA_SET_NAME"
EOF
}

start_mongodb()
{
	log "Starting MongoDB daemon processes"
	service mongod start
	
	# Wait for MongoDB daemon to start and initialize for the first time (this may take up to a minute or so)
	while ! timeout 1 bash -c "echo > /dev/tcp/localhost/$MONGODB_PORT"; do sleep 10; done
}

stop_mongodb()
{
	# Find out what PID the MongoDB instance is running as (if any)
	MONGOPID=`ps -ef | grep '/usr/bin/mongod' | grep -v grep | awk '{print $2}'`
	
	if [ ! -z "$MONGOPID" ]; then
		log "Stopping MongoDB daemon processes (PID $MONGOPID)"
		
		kill -15 $MONGOPID
	fi
	
	# Important not to attempt to start the daemon immediately after it was stopped as unclean shutdown may be wrongly perceived
	sleep 15s	
}

configure_db_users()
{
	# Create a system administrator
	log "Creating a system administrator"
	mongo master --host 127.0.0.1 --eval "db.createUser({user: '${ADMIN_USER_NAME}', pwd: '${ADMIN_USER_PASSWORD}', roles:[{ role: 'userAdminAnyDatabase', db: 'admin' }, { role: 'clusterAdmin', db: 'admin' }, { role: 'readWriteAnyDatabase', db: 'admin' }, { role: 'dbAdminAnyDatabase', db: 'admin' } ]})"
	mongo tasks --host 127.0.0.1 --eval "db.createUser({user: '${ADMIN_USER_NAME}', pwd: '${ADMIN_USER_PASSWORD}', roles:[{ role: 'userAdminAnyDatabase', db: 'admin' }, { role: 'clusterAdmin', db: 'admin' }, { role: 'readWriteAnyDatabase', db: 'admin' }, { role: 'dbAdminAnyDatabase', db: 'admin' } ]})"

}

# Step 1
configure_datadisks

# Step 2
tune_memory
tune_system

# Step 3
install_mongodb

# Step 4
configure_mongodb

# Step 5
start_mongodb

# Step 6
configure_db_users

# Step 7
configure_replicaset

# Exit (proudly)
exit 0
