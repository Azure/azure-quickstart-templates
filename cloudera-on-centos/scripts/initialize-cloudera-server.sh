#!/usr/bin/env bash

LOG_FILE="/var/log/cloudera-azure-initialize.log"

EXECNAME=$0

# logs everything to the $LOG_FILE
log() {
  echo "$(date) [${EXECNAME}]: $*" >> "${LOG_FILE}"
}

#fail on any error
set -e

ClusterName=$1
key=$2
mip=$3
worker_ip=$4
HA=$5
User=$6
Password=$7

cmUser=$8
cmPassword=$9

EMAILADDRESS=${10}
BUSINESSPHONE=${11}
FIRSTNAME=${12}
LASTNAME=${13}
JOBROLE=${14}
JOBFUNCTION=${15}
COMPANY=${16}
VMSIZE=${17}

log "------- initialize-cloudera.sh starting -------"

log "BEGIN: master node deployments"

log "Beginning process of disabling SELinux"

log "Running as $(whoami) on $(hostname)"

# Use the Cloudera-documentation-suggested workaround
log "about to set setenforce to 0"
set +e
setenforce 0

exitcode=$?
log "Done with settiing enforce. Its exit code was $exitcode"

log "Running setenforce inline as $(setenforce 0)"

getenforce
log "Running getenforce inline as $(getenforce)"
getenforce

log "should be done logging things"


cat /etc/selinux/config > /tmp/beforeSelinux.out
log "ABOUT to replace enforcing with disabled"
sed -i 's^SELINUX=enforcing^SELINUX=disabled^g' /etc/selinux/config || true

cat /etc/selinux/config > /tmp/afterSeLinux.out
log "Done disabling selinux"

set +e

log "Set cloudera-manager.repo to CM v5"
yum clean all >> "${LOG_FILE}" 2>&1
rpm --import http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera >> "${LOG_FILE}" 2>&1
wget http://archive.cloudera.com/cm5/redhat/6/x86_64/cm/cloudera-manager.repo -O /etc/yum.repos.d/cloudera-manager.repo >> "${LOG_FILE}" 2>&1
# this often fails so adding retry logic
n=0
until [ $n -ge 5 ]
do
    yum install -y oracle-j2sdk* cloudera-manager-daemons cloudera-manager-server >> "${LOG_FILE}" 2>&1 && break
    n=$((n+1))
    sleep 15s
done
if [ $n -ge 5 ]
then 
    log "yum install error, exiting..."
    log "------- initialize-cloudera-server.sh failed -------" 
    exit 1
fi

#######################################################################################################################
log "installing external DB"
sudo yum install postgresql-server -y
bash install-postgresql.sh >> "${LOG_FILE}" 2>&1

log "finished installing external DB"
#######################################################################################################################

log "start cloudera-scm-server services"
#service cloudera-scm-server-db start >> "${LOG_FILE}" 2>&1
service cloudera-scm-server start >> "${LOG_FILE}" 2>&1

#log "Create HIVE metastore DB Cloudera embedded PostgreSQL"
#export PGPASSWORD=$(head -1 /var/lib/cloudera-scm-server-db/data/generated_password.txt)
#SQLCMD=( """CREATE ROLE hive LOGIN PASSWORD 'hive';""" """CREATE DATABASE hive OWNER hive ENCODING 'UTF8';""" """ALTER DATABASE hive SET standard_conforming_strings = off;""" )
#for SQL in "${SQLCMD[@]}"; do
#	psql -A -t -d scm -U cloudera-scm -h localhost -p 5432 -c "${SQL}" >> "${LOG_FILE}"
#done
while ! (exec 6<>/dev/tcp/"$(hostname)"/7180) ; do log 'Waiting for cloudera-scm-server to start...'; sleep 15; done
log "END: master node deployments"



# Set up python
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm >> "${LOG_FILE}" 2>&1
yum -y install python-pip >> "${LOG_FILE}" 2>&1
pip install cm_api >> "${LOG_FILE}" 2>&1

# trap file to indicate done
log "creating file to indicate finished"
touch /tmp/readyFile

# Execute script to deploy Cloudera cluster
log "BEGIN: CM deployment - starting"
log "Parameters: $ClusterName $mip $worker_ip $EMAILADDRESS $BUSINESSPHONE $FIRSTNAME $LASTNAME $JOBROLE $JOBFUNCTION $COMPANY $VMSIZE"
status=0
if $HA; then
    python cmxDeployOnIbiza.py -n "$ClusterName" -u "$User" -p "$Password" -m "$mip" -w "$worker_ip" -a -c "$cmUser" -s "$cmPassword" -e -r "$EMAILADDRESS" -b "$BUSINESSPHONE" -f "$FIRSTNAME" -t "$LASTNAME" -o "$JOBROLE" -i "$JOBFUNCTION" -y "$COMPANY" -v "$VMSIZE" >> "${LOG_FILE}" 2>&1
    status=$?
else
    python cmxDeployOnIbiza.py -n "$ClusterName" -u "$User" -p "$Password" -m "$mip" -w "$worker_ip" -c "$cmUser" -s "$cmPassword" -e -r "$EMAILADDRESS" -b "$BUSINESSPHONE" -f "$FIRSTNAME" -t "$LASTNAME" -o "$JOBROLE" -i "$JOBFUNCTION" -y "$COMPANY" -v "$VMSIZE" >> "${LOG_FILE}" 2>&1
    status=$?
fi

log "END: CM deployment ended with status '$status'"

if [ $status -eq 0 ]
then
    log "------- initialize-cloudera-server.sh succeeded -------" 
    # always `exit 0` on success
    exit 0

else
    log "------- initialize-cloudera-server.sh failed -------" 
    exit 1
fi

