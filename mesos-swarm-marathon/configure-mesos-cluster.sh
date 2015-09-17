#!/bin/bash

###########################################################
# Configure Mesos One Box
#
# This installs the following components
# - zookeepr
# - mesos master
# - marathon
# - mesos agent
###########################################################

set -x

echo "starting mesos cluster configuration"
ps ax

#############
# Parameters
#############

MASTERCOUNT=$1
MASTERMODE=$2
MASTERPREFIX=$3
SWARMENABLED=$4
MARATHONENABLED=$5
CHRONOSENABLED=$6
ACCOUNTNAME=$7
set +x
ACCOUNTKEY=$8
set -x
VMNAME=`hostname`
VMNUMBER=`echo $VMNAME | sed 's/.*[^0-9]\([0-9]\+\)*$/\1/'`
VMPREFIX=`echo $VMNAME | sed 's/\(.*[^0-9]\)*[0-9]\+$/\1/'`

echo "Master Count: $MASTERCOUNT"
echo "Master Mode: $MASTERMODE"
echo "Master Prefix: $MASTERPREFIX"
echo "vmname: $VMNAME"
echo "VMNUMBER: $VMNUMBER, VMPREFIX: $VMPREFIX"
echo "SWARMENABLED: $SWARMENABLED, MARATHONENABLED: $MARATHONENABLED, CHRONOSENABLED: $CHRONOSENABLED"
echo "ACCOUNTNAME: $ACCOUNTNAME"

###################
# Common Functions
###################

ensureAzureNetwork()
{
  # ensure the host name is resolvable
  hostResolveHealthy=1
  for i in {1..120}; do
    host $VMNAME
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      hostResolveHealthy=0
      echo "the host name resolves"
      break
    fi
    sleep 1
  done
  if [ $hostResolveHealthy -ne 0 ]
  then
    echo "host name does not resolve, aborting install"
    exit 1
  fi

  # ensure the network works
  networkHealthy=1
  for i in {1..12}; do
    wget -O/dev/null http://bing.com
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      networkHealthy=0
      echo "the network is healthy"
      break
    fi
    sleep 10
  done
  if [ $networkHealthy -ne 0 ]
  then
    echo "the network is not healthy, aborting install"
    ifconfig
    ip a
    exit 2
  fi
}
ensureAzureNetwork

ismaster ()
{
  if [ "$MASTERPREFIX" == "$VMPREFIX" ]
  then
    return 0
  else
    return 1
  fi
}
if ismaster ; then
  echo "this node is a master"
fi

isagent()
{
  if ismaster ; then
    if [ "$MASTERMODE" == "masters-are-agents" ]
    then
      return 0
    else
      return 1
    fi
  else
    return 0
  fi
}
if isagent ; then
  echo "this node is an agent"
fi

zkhosts()
{
  zkhosts=""
  for i in `seq 1 $MASTERCOUNT` ;
  do
    if [ "$i" -gt "1" ]
    then
      zkhosts="${zkhosts},"
    fi
    zkhosts="${zkhosts}${MASTERPREFIX}${i}:2181"
  done
  echo $zkhosts
}

zkconfig()
{
  postfix="$1"
  zkhosts=$(zkhosts)
  zkconfigstr="zk://${zkhosts}/${postfix}"
  echo $zkconfigstr
}

################
# Install Docker
################

echo "Installing and configuring docker and swarm"

time wget -qO- https://get.docker.com | sh

# Start Docker and listen on :2375 (no auth, but in vnet)
echo 'DOCKER_OPTS="-H unix:///var/run/docker.sock -H 0.0.0.0:2375"' | sudo tee /etc/default/docker
echo 'DOCKER_OPTS="$DOCKER_OPTS --insecure-registry 137.135.93.9"' | sudo tee -a /etc/default/docker
sudo service docker restart

ensureDocker()
{
  # ensure that docker is healthy
  dockerHealthy=1
  for i in {1..3}; do
    sudo docker info
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      dockerHealthy=0
      echo "Docker is healthy"
      sudo docker ps -a
      break
    fi
    sleep 10
  done
  if [ $dockerHealthy -ne 0 ]
  then
    echo "Docker is not healthy"
  fi
}
ensureDocker

############
# setup OMS
############

if [ $ACCOUNTNAME != "none" ]
then
  set +x
  EPSTRING="DefaultEndpointsProtocol=https;AccountName=${ACCOUNTNAME};AccountKey=${ACCOUNTKEY}"
  docker run --restart=always -d 137.135.93.9/msdockeragentv3 http://${VMNAME}:2375 "${EPSTRING}"
  set -x
fi

##################
# Install Mesos
##################

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
time sudo apt-get -y update
if ismaster ; then
  time sudo apt-get -y --force-yes install mesosphere
else
  time sudo apt-get -y --force-yes install mesos
fi

#########################
# Configure ZooKeeper
#########################

zkmesosconfig=$(zkconfig "mesos")
echo $zkmesosconfig | sudo tee /etc/mesos/zk

if ismaster ; then
  echo $VMNUMBER | sudo tee /etc/zookeeper/conf/myid
  for i in `seq 1 $MASTERCOUNT` ;
  do
    echo "server.${i}=${MASTERPREFIX}${i}:2888:3888" | sudo tee -a /etc/zookeeper/conf/zoo.cfg
  done
fi

#########################################
# Configure Mesos Master and Frameworks
#########################################
if ismaster ; then
  quorum=`expr $MASTERCOUNT / 2 + 1`
  echo $quorum | sudo tee /etc/mesos-master/quorum
  hostname -i | sudo tee /etc/mesos-master/ip
  hostname | sudo tee /etc/mesos-master/hostname
  echo 'Mesos Cluster on Microsoft Azure' | sudo tee /etc/mesos-master/cluster
fi

if ismaster  && [ "$MARATHONENABLED" == "true" ] ; then
  # setup marathon
  sudo mkdir -p /etc/marathon/conf
  sudo cp /etc/mesos-master/hostname /etc/marathon/conf
  sudo cp /etc/mesos/zk /etc/marathon/conf/master
  zkmarathonconfig=$(zkconfig "marathon")
  echo $zkmarathonconfig | sudo tee /etc/marathon/conf/zk
fi

#########################
# Configure Mesos Agent
#########################
if isagent ; then
  # Add docker containerizer
  echo "docker,mesos" | sudo tee /etc/mesos-slave/containerizers
  hostname -i | sudo tee /etc/mesos-slave/ip
  hostname | sudo tee /etc/mesos-slave/hostname
fi

##############################################
# configure init rules restart all processes
##############################################

echo "(re)starting mesos and framework processes"
if ismaster ; then
  sudo service zookeeper restart
  sudo service mesos-master start
  if [ "$MARATHONENABLED" == "true" ] ; then
    sudo service marathon start
  fi
  if [ "$CHRONOSENABLED" == "true" ] ; then
    sudo service chronos start
  fi
else
  echo manual | sudo tee /etc/init/zookeeper.override
  sudo service zookeeper stop
  echo manual | sudo tee /etc/init/mesos-master.override
  sudo service mesos-master stop
fi

if isagent ; then
  echo "starting mesos-slave"
  sudo service mesos-slave start
  echo "completed starting mesos-slave with code $?"
else
  echo manual | sudo tee /etc/init/mesos-slave.override
  sudo service mesos-slave stop
fi

echo "processes after restarting mesos"
ps ax

# Run swarm manager container on port 2376 (no auth)
if [ ismaster ] && [ "$SWARMENABLED" == "true" ] ; then
  echo "starting docker swarm"
  echo "sleep to give master time to come up"
  sleep 10
  echo sudo docker run -d -e SWARM_MESOS_USER=root \
      --restart=always \
      -p 2376:2375 -p 3375:3375 swarm manage \
      -c mesos-experimental \
      --cluster-opt mesos.address=0.0.0.0 \
      --cluster-opt mesos.port=3375 $zkmesosconfig
  sudo docker run -d -e SWARM_MESOS_USER=root \
      --restart=always \
      -p 2376:2375 -p 3375:3375 swarm manage \
      -c mesos-experimental \
      --cluster-opt mesos.address=0.0.0.0 \
      --cluster-opt mesos.port=3375 $zkmesosconfig
  sudo docker ps
  echo "completed starting docker swarm"
fi
echo "processes at end of script"
ps ax
echo "Finished installing and configuring docker and swarm"

echo "completed mesos cluster configuration"
