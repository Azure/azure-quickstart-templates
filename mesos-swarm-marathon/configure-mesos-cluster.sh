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

echo "starting mesos cluster configuration"

#############
# Parameters
#############

MASTERCOUNT=$1
MASTERMODE=$2
MASTERPREFIX=$3
VMNAME=`hostname`
VMNUMBER=`echo $VMNAME | sed 's/.*[^0-9]\([0-9]\+\)*$/\1/'`
VMPREFIX=`echo $VMNAME | sed 's/\(.*[^0-9]\)*[0-9]\+$/\1/'`

echo "Master Count: $MASTERCOUNT"
echo "Master Mode: $MASTERMODE"
echo "Master Prefix: $MASTERPREFIX"
echo "vmname: $VMNAME"
echo "VMNUMBER: $VMNUMBER, VMPREFIX: $VMPREFIX"

###################
# Common Functions
###################

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

zkconfig()
{
  postfix="$1"
  zkconfigstr="zk://"
  for i in `seq 1 $MASTERCOUNT` ;
  do
    if [ "$i" -gt "1" ]
    then
      zkconfigstr="${zkconfigstr},"
    fi
    zkconfigstr="${zkconfigstr}${MASTERPREFIX}${i}:2181"
  done
  zkconfigstr="${zkconfigstr}/${postfix}"
  echo $zkconfigstr
}

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

#########################
# Configure Mesos Master
#########################
if ismaster ; then
  quorum=`expr $MASTERCOUNT / 2 + 1`
  echo $quorum | sudo tee /etc/mesos-master/quorum
  hostname -i | sudo tee /etc/mesos-master/ip
  hostname | sudo tee /etc/mesos-master/hostname
  sudo mkdir -p /etc/marathon/conf
  sudo cp /etc/mesos-master/hostname /etc/marathon/conf
  sudo cp /etc/mesos/zk /etc/marathon/conf/master
  zkmarathonconfig=$(zkconfig "marathon")
  echo $zkmarathonconfig | sudo tee /etc/marathon/conf/zk
  echo 'Mesos Cluster on Microsoft Azure' | sudo tee /etc/mesos-master/cluster
fi

#########################
# Configure Mesos Agent
#########################
if isagent ; then
  hostname -i | sudo tee /etc/mesos-slave/ip
  hostname | sudo tee /etc/mesos-slave/hostname
fi

################
# Install Docker
################

echo "Installing and configuring docker and swarm"

time wget -qO- https://get.docker.com | sh

if isagent ; then
  # Start Docker and listen on :2375 (no auth, but in vnet)
  echo 'DOCKER_OPTS="-H unix:// -H 0.0.0.0:2375"' | sudo tee /etc/default/docker
  sudo service docker restart
fi

# Run swarm manager container on port 2376 (no auth)
if ismaster ; then
  time sudo docker run -d -e SWARM_MESOS_USER=root \
      --restart=always \
      -p 2376:2375 -p 3375:3375 swarm manage \
      -c mesos-experimental \
      --cluster-opt mesos.address=0.0.0.0 \
      --cluster-opt mesos.port=3375 $masterVMName:5050
fi

echo "Finished installing and configuring docker and swarm"

##############################################
# configure init rules restart all processes
##############################################

echo "restarting mesos processes"
if ismaster ; then
  sudo restart zookeeper
  sudo start mesos-master
  sudo start marathon
else
  echo manual | sudo tee /etc/init/zookeeper.override
  sudo stop zookeeper
  echo manual | sudo tee /etc/init/mesos-master.override
  sudo-stop mesos-master
fi

if isagent ; then
  sudo start mesos-slave
else
  echo manual | sudo tee /etc/init/mesos-slave.override
  sudo stop mesos-slave
fi

echo "completed mesos cluster configuration"
