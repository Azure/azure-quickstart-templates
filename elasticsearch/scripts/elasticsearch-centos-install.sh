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
#
# Trent Swanson (Full Scale 180 Inc)
#
help()
{
    echo "This script installs Elasticsearch cluster on CentOS"
    echo "Parameters:"
    echo "-n elasticsearch cluster name"
    echo "-d static discovery endpoints 10.0.0.1-3"
    echo "-v elasticsearch version"
    echo "-a storage account (for AFS)"
    echo "-k access key (for AFS)"
    echo "-c create and mount AFS share"
    echo "-m install marvel yes/no"
    echo "-e export marvel data to a different ip"
    echo "-w configure as a dedicated marvel node"
    echo "-x configure as a dedicated master node"
    echo "-y configure as client only node (no master, no data)"
    echo "-z configure as data node (no master)"
    echo "-s used striped data disk volumes"
    echo "-j install jmeter server agent"
    echo "-p install the cloud-azure plugin"
    echo "-o storage account (for cloud-azure)"
    echo "-r storage key (for cloud-azure)"
    echo "-h view this help content"
}

# Log method to control/redirect log output
log()
{
    # If you want to enable this logging add a un-comment the line below and add your account id
    #curl -X POST -H "content-type:text/plain" --data-binary "${HOSTNAME} - $1" https://logs-01.loggly.com/inputs/<key>/tag/es-extension,${HOSTNAME}
    echo "$1"
}

log "Begin execution of Elasticsearch script extension on ${HOSTNAME}"

if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

# TEMP FIX - Re-evaluate and remove when possible
# This is an interim fix for hostname resolution in current VM
#grep -q "${HOSTNAME}" /etc/hosts
#if [ $? == 0 ]
#then
#  echo "${HOSTNAME}found in /etc/hosts"
#else
#  echo "${HOSTNAME} not found in /etc/hosts"
  # Append it to the hosts file if not there
#  echo "127.0.0.1 ${HOSTNAME}" >> /etc/hosts
  log "hostname ${HOSTNAME} added to /etc/hosts"
#fi

#Script Parameters
CLUSTER_NAME="elasticsearch"
ES_VERSION="2.0.0"
MARVEL_ONLY_NODE=0
DISCOVERY_ENDPOINTS=""
INSTALL_MARVEL=0
CLIENT_ONLY_NODE=0
DATA_NODE=0
MASTER_ONLY_NODE=0
USE_AFS=0
STORAGE_ACCOUNT=""
ACCESS_KEY=""
INSTALL_CLOUD_AZURE=0
CLOUD_AZURE_ACCOUNT=""
CLOUD_AZURE_KEY=""

#Loop through options passed
while getopts :n:d:v:a:k:cme:o:r:pwxyzsjh optname; do
  log "Option $optname set with value ${OPTARG}"
  case $optname in
    n) #set cluster name
      CLUSTER_NAME=${OPTARG}
      ;;
    d) #static discovery endpoints
      DISCOVERY_ENDPOINTS=${OPTARG}
      ;;
    v) #elasticsearch version number
      ES_VERSION=${OPTARG}
      ;;
    m) #install marvel
      INSTALL_MARVEL=1
      ;;
    e) #export marvel data
      MARVEL_ENDPOINTS=${OPTARG}
      ;;
    w) #marvel node
      MARVEL_ONLY_NODE=1
      ;;
    x) #master node
      MASTER_ONLY_NODE=1
      ;;
    y) #client node
      CLIENT_ONLY_NODE=1
      ;;
    z) #data node
      DATA_NODE=1
      ;;
    s) #use OS striped disk volumes
      OS_STRIPED_DISK=1
      ;;
    a) #set the storage account for AFS
      STORAGE_ACCOUNT=${OPTARG}
      ;;
    k) #set the access key for AFS
      ACCESS_KEY=${OPTARG}
      ;;
    c) #use AFS for the data storage
      USE_AFS=1
      ;;
    d) #place data on local resource disk
      NON_DURABLE=1
      ;;
    j) #install jmeter server agent
      JMETER_AGENT=1
      ;;
    p) #install cloud-azure plugin
      INSTALL_CLOUD_AZURE=1
      ;;
    o) #set cloud-azure account
      CLOUD_AZURE_ACCOUNT=${OPTARG}
      ;;
    r) #set the cloud-azure account key
      CLOUD_AZURE_KEY=${OPTARG}
      ;;
    h) #show help
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

# Base path for data disk mount points
# The script assume format /datadisks/disk1 /datadisks/disk2
DATA_BASE="/datadisks"

# Max retry count
MAX_RETRY=5

# Expand a list of successive ip range and filter my local local ip from the list
# Ip list is represented as a prefix and that is appended with a zero to N index
# 10.0.0.1-3 would be converted to "10.0.0.10 10.0.0.11 10.0.0.12"
expand_ip_range() {
    IFS='-' read -a HOST_IPS <<< "$1"

    #Get the IP Addresses on this machine
    declare -a MY_IPS=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
    declare -a EXPAND_STATICIP_RANGE_RESULTS=()
    for (( n=0 ; n<("${HOST_IPS[1]}"+0) ; n++))
    do
        HOST="${HOST_IPS[0]}${n}"
        if ! [[ "${MY_IPS[@]}" =~ "${HOST}" ]]; then
            EXPAND_STATICIP_RANGE_RESULTS+=($HOST)
        fi
    done
    echo "${EXPAND_STATICIP_RANGE_RESULTS[@]}"
}

# Configure Elasticsearch Data Disk Folder and Permissions
setup_data_disk()
{
    log "Configuring disk $1"

    mkdir -p "$1"
    chown -R elasticsearch:elasticsearch "$1"
    chmod 755 "$1"
}

# Install Oracle Java
install_java()
{
    log "Installing Java"
    RETRY=0
    while [ $RETRY -lt $MAX_RETRY ]; do
        log "Retry $RETRY: downloading jdk-8u92-linux-x64.rpm..."
        wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u92-b14/jdk-8u92-linux-x64.rpm
        if [ $? -ne 0 ]; then
            let RETRY=RETRY+1
        else
            break
        fi
    done
    if [ $RETRY -eq $MAX_RETRY ]; then
        log "Failed to download jdk-8u92-linux-x64.rpm."
        exit 1
    fi
    yum -y localinstall jdk-8u92-linux-x64.rpm
#    rm ~/jdk-8u*-linux-x64.rpm
}

# Install Elasticsearch
install_es()
{
	# Import the Elasticsearch public GPG key into RPM
    RETRY=0
    while [ $RETRY -lt $MAX_RETRY ]; do
        log "Retry $RETRY: importing GPG-KEY-elasticsearch..."
        rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch
        if [ $? -ne 0 ]; then
            let RETRY=RETRY+1
        else
            break
        fi
    done
    if [ $RETRY -eq $MAX_RETRY ]; then
        log "Failed to import GPG-KEY-elasticsearch."
        exit 1
    fi
    
    # Create a new yum repository file for Elasticsearch
    if [[ "${ES_VERSION}" == \2* ]]; then
        echo '[elasticsearch-2.x]
name=Elasticsearch repository for 2.x packages
baseurl=http://packages.elastic.co/elasticsearch/2.x/centos
gpgcheck=1
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1' | tee /etc/yum.repos.d/elasticsearch.repo
    fi
    
    if [[ "${ES_VERSION}" == \1* ]]; then
        echo '[elasticsearch-1.7]
name=Elasticsearch repository for 1.7.x packages
baseurl=http://packages.elastic.co/elasticsearch/1.7/centos
gpgcheck=1
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1' | tee /etc/yum.repos.d/elasticsearch.repo    
    fi
    
    # Install Elasticsearch
    RETRY=0
    while [ $RETRY -lt $MAX_RETRY ]; do
        log "Retry $RETRY: installing elasticsearch..."
        yum -y install elasticsearch-${ES_VERSION}
        if [ $? -ne 0 ]; then
            let RETRY=RETRY+1
        else
            break
        fi
    done
    if [ $RETRY -eq $MAX_RETRY ]; then
        log "Failed to install elasticsearch."
        exit 1
    fi
    
}

# Primary Install Tasks
#########################
#NOTE: These first three could be changed to run in parallel
#      Future enhancement - (export the functions and use background/wait to run in parallel)


#if [ ${USE_AFS} -ne 0 ]; 
#then
#    log "setting up afs"
    
    # install cachefilesd
    # disabled for more extensive testing
    ##apt-get install cachefilesd
    ##echo "RUN=yes" >> /etc/default/cachefilesd
    ##service cachefilesd start

    # create and mount an AFS share
#    bash afs-utils-0.1.sh -cp -a ${STORAGE_ACCOUNT} -k ${ACCESS_KEY}
#else
#    log "setting up disks"
    
    #Format data disks (Find data disks then partition, format, and mount them as separate drives)
bash vm-disk-utils-0.1.sh    
#fi

#Install Oracle Java
#------------------------
install_java

#
#Install Elasticsearch
#-----------------------
install_es

#install jmeter server agent
#if [ $JMETER_AGENT ]; 
#then
#    install_jmeter_server
#fi

# Prepare configuration information
# Configure permissions on data disks for elasticsearch user:group
#--------------------------
DATAPATH_CONFIG=""
if [ -d "${DATA_BASE}" ]; then
    for D in `find /datadisks/ -mindepth 1 -maxdepth 1 -type d`
    do
        #Configure disk permissions and folder for storage
        setup_data_disk ${D}
        # Add to list for elasticsearch configuration
        DATAPATH_CONFIG+="$D,"
    done
    #Remove the extra trailing comma
    DATAPATH_CONFIG="${DATAPATH_CONFIG%?}"
else
    #If we do not find folders/disks in our data disk mount directory then use the defaults
    log "Configured data directory does not exist for ${HOSTNAME} using defaults"
fi

#expand_staticip_range "$IP_RANGE"

S=$(expand_ip_range "$DISCOVERY_ENDPOINTS")
HOSTS_CONFIG="[\"${S// /\",\"}\"]"

#Format the static discovery host endpoints for Elasticsearch configuration ["",""] format
#HOSTS_CONFIG="[\"${DISCOVERY_ENDPOINTS//-/\",\"}\"]"

#Configure Elasticsearch settings
#---------------------------
#Backup the current Elasticsearch configuration file
mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.bak

# Set cluster and machine names - just use hostname for our node.name
echo "cluster.name: $CLUSTER_NAME" >> /etc/elasticsearch/elasticsearch.yml
echo "node.name: ${HOSTNAME}" >> /etc/elasticsearch/elasticsearch.yml

# Configure paths - if we have data disks attached then use them
if [ -n "$DATAPATH_CONFIG" ]; then
    log "Update configuration with data path list of $DATAPATH_CONFIG"
    echo "path.data: $DATAPATH_CONFIG" >> /etc/elasticsearch/elasticsearch.yml
fi

# if we are using AFS, then add that path
#if [ ${USE_AFS} -ne 0 ]; 
#then
#    echo "node.enable_custom_paths: true" >> /etc/elasticsearch/elasticsearch.yml
#    echo "node.add_id_to_custom_path: false" >> /etc/elasticsearch/elasticsearch.yml
#    echo "path.shared_data: /sharedfs" >> /etc/elasticsearch/elasticsearch.yml        
#fi

# Configure discovery
log "Update configuration with hosts configuration of $HOSTS_CONFIG"
echo "discovery.zen.ping.multicast.enabled: false" >> /etc/elasticsearch/elasticsearch.yml
echo "discovery.zen.ping.unicast.hosts: $HOSTS_CONFIG" >> /etc/elasticsearch/elasticsearch.yml

# Configure Elasticsearch node type
log "Configure master/client/data node type flags master-$MASTER_ONLY_NODE data-$DATA_NODE"

if [ ${MASTER_ONLY_NODE} -ne 0 ]; then
    log "Configure node as master only"
    echo "node.master: true" >> /etc/elasticsearch/elasticsearch.yml
    echo "node.data: false" >> /etc/elasticsearch/elasticsearch.yml
elif [ ${DATA_NODE} -ne 0 ]; then
    log "Configure node as data only"
    echo "node.master: false" >> /etc/elasticsearch/elasticsearch.yml
    echo "node.data: true" >> /etc/elasticsearch/elasticsearch.yml
elif [ ${CLIENT_ONLY_NODE} -ne 0 ]; then
    log "Configure node as client only"
    echo "node.master: false" >> /etc/elasticsearch/elasticsearch.yml
    echo "node.data: false" >> /etc/elasticsearch/elasticsearch.yml
else
    log "Configure node for master and data"
    echo "node.master: true" >> /etc/elasticsearch/elasticsearch.yml
    echo "node.data: true" >> /etc/elasticsearch/elasticsearch.yml
fi

echo "discovery.zen.minimum_master_nodes: 2" >> /etc/elasticsearch/elasticsearch.yml

if [[ "${ES_VERSION}" == \2* ]]; then
    echo "network.host: _non_loopback_" >> /etc/elasticsearch/elasticsearch.yml
fi

if [[ "${MARVEL_ENDPOINTS}" ]]; then
  # non-Marvel node
  mep=$(expand_ip_range "$MARVEL_ENDPOINTS")
  expanded_marvel_endpoints="[\"${mep// /\",\"}\"]"
  
  if [[ "${ES_VERSION}" == \2* ]]; then
    # 2.x non-Marvel node
    echo "marvel.agent.exporters:" >> /etc/elasticsearch/elasticsearch.yml
    echo "  id1:" >> /etc/elasticsearch/elasticsearch.yml
    echo "    type: http" >> /etc/elasticsearch/elasticsearch.yml
    echo "    host: ${expanded_marvel_endpoints}" >> /etc/elasticsearch/elasticsearch.yml
  else
    # 1.x non-Marvel node
    echo "marvel.agent.exporter.hosts: ${expanded_marvel_endpoints}" >> /etc/elasticsearch/elasticsearch.yml
  fi
fi

if [[ ${MARVEL_ONLY_NODE} -ne 0 && "${ES_VERSION}" == \1* ]]; then
  # 1.x Marvel node
  echo "marvel.agent.enabled: false" >> /etc/elasticsearch/elasticsearch.yml
fi

# DNS Retry
echo "options timeout:1 attempts:5" >> /etc/resolv.conf

# Increase maximum mmap count
echo "vm.max_map_count = 262144" >> /etc/sysctl.conf

#"action.disable_delete_all_indices: ${DISABLE_DELETE_ALL}" >> /etc/elasticsearch/elasticsearch.yml
#"action.auto_create_index: ${AUTOCREATE_INDEX}" >> /etc/elasticsearch/elasticsearch.yml

# Configure Environment
#----------------------
#/etc/default/elasticseach
#Update HEAP Size in this configuration or in upstart service
#Set Elasticsearch heap size to 50% of system memory
#TODO: Move this to an init.d script so we can handle instance size increases
#TODO: Client nodes should use 75% of the heap
ES_HEAP=`free -m |grep Mem | awk '{if ($2/2 >31744)  print 31744;else print $2/2;}'`
log "Configure elasticsearch heap size - $ES_HEAP"
echo "ES_HEAP_SIZE=${ES_HEAP}m" >> /etc/default/elasticsearch

#Optionally Install Marvel
if [ ${INSTALL_MARVEL} -ne 0 ]; then
    log "Installing Marvel Plugin"
    if [[ "${ES_VERSION}" == \2* ]]; then
        RETRY=0
        while [ $RETRY -lt $MAX_RETRY ]; do
            log "Retry $RETRY: installing plugin license..."
            /usr/share/elasticsearch/bin/plugin install license
            if [ $? -ne 0 ]; then
                let RETRY=RETRY+1
            else
                break
            fi
        done
        if [ $RETRY -eq $MAX_RETRY ]; then
            log "Failed to install plugin license."
            exit 1
        fi

        RETRY=0
        while [ $RETRY -lt $MAX_RETRY ]; do
            log "Retry $RETRY: installing plugin marvel-agent..."
            echo y | /usr/share/elasticsearch/bin/plugin install marvel-agent
            if [ $? -ne 0 ]; then
                let RETRY=RETRY+1
            else
                break
            fi
        done
        if [ $RETRY -eq $MAX_RETRY ]; then
            log "Failed to install plugin marvel-agent."
            exit 1
        fi
        
    else
        RETRY=0
        while [ $RETRY -lt $MAX_RETRY ]; do
            log "Retry $RETRY: installing Marvel plugin..."
            /usr/share/elasticsearch/bin/plugin -i elasticsearch/marvel/1.3.1
            if [ $? -ne 0 ]; then
                let RETRY=RETRY+1
            else
                break
            fi
        done
        if [ $RETRY -eq $MAX_RETRY ]; then
            log "Failed to install Marvel plugin."
            exit 1
        fi
        
        
    fi
fi

# install the cloud-azure plugin
if [ ${INSTALL_CLOUD_AZURE} -ne 0 ]; then
    log "Installing Cloud-Azure Plugin"
    if [[ "${ES_VERSION}" == \2* ]]; then
        /usr/share/elasticsearch/bin/plugin install cloud-azure
        echo "cloud.azure.storage.default.account: ${CLOUD_AZURE_ACCOUNT}" >> /etc/elasticsearch/elasticsearch.yml
        echo "cloud.azure.storage.default.key: ${CLOUD_AZURE_KEY}" >> /etc/elasticsearch/elasticsearch.yml
    else
        /usr/share/elasticsearch/bin/plugin -i elasticsearch/elasticsearch-cloud-azure/2.8.2
        echo "cloud.azure.storage.account: ${CLOUD_AZURE_ACCOUNT}" >> /etc/elasticsearch/elasticsearch.yml
        echo "cloud.azure.storage.key: ${CLOUD_AZURE_KEY}" >> /etc/elasticsearch/elasticsearch.yml
    fi
fi

# start the service
log "Starting Elasticsearch on ${HOSTNAME}"
systemctl start elasticsearch
systemctl enable elasticsearch
log "complete elasticsearch setup and started, checking status..."

service elasticsearch status
if [ $? -ne 0 ]; then
    log "elasticsearch service is in unhealthy state, exit"
    exit 1
fi

exit 0

#Script Extras

#Configure open file and memory limits
#Swap is disabled by default in Ubuntu Azure VMs
#echo "bootstrap.mlockall: true" >> /etc/elasticsearch/elasticsearch.yml

# Verify this is necessary on azure
#echo "elasticsearch    -    nofile    65536" >> /etc/security/limits.conf
#echo "elasticsearch     -    memlock   unlimited" >> /etc/security/limits.conf
#echo "session    required    pam_limits.so" >> /etc/pam.d/su
#echo "session    required    pam_limits.so" >> /etc/pam.d/common-session
#echo "session    required    pam_limits.so" >> /etc/pam.d/common-session-noninteractive
#echo "session    required    pam_limits.so" >> /etc/pam.d/sudo

#--------------- TEMP (We will use this for the update path yet) ---------------
#Updating the properties in the existing configuraiton has been a bit sensitve and requires more testing
#sed -i -e "/cluster\.name/s/^#//g;s/^\(cluster\.name\s*:\s*\).*\$/\1${CLUSTER_NAME}/" /etc/elasticsearch/elasticsearch.yml
#sed -i -e "/bootstrap\.mlockall/s/^#//g;s/^\(bootstrap\.mlockall\s*:\s*\).*\$/\1true/" /etc/elasticsearch/elasticsearch.yml
#sed -i -e "/path\.data/s/^#//g;s/^\(path\.data\s*:\s*\).*\$/\1${DATAPATH_CONFIG}/" /etc/elasticsearch/elasticsearch.yml

# Minimum master nodes nodes/2+1 (These can be configured via API as well - (_cluster/settings))
# discovery.zen.minimum_master_nodes: 2
# gateway.expected_nodes: 10
# gateway.recover_after_time: 5m
#----------------------
