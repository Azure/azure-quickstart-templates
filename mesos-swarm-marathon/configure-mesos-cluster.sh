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
date
ps ax

SWARM_VERSION="1.0.0-rc2"

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
AZUREUSER=$9
SSHKEY=${10}
HOMEDIR="/home/$AZUREUSER"
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
# setup ssh access
###################

SSHDIR=$HOMEDIR/.ssh
AUTHFILE=$SSHDIR/authorized_keys
if [ `echo $SSHKEY | sed 's/^\(ssh-rsa \).*/\1/'` == "ssh-rsa" ] ; then
  if [ ! -d $SSHDIR ] ; then
    sudo -i -u $AZUREUSER mkdir $SSHDIR
    sudo -i -u $AZUREUSER chmod 700 $SSHDIR
  fi

  if [ ! -e $AUTHFILE ] ; then
    sudo -i -u $AZUREUSER touch $AUTHFILE
    sudo -i -u $AZUREUSER chmod 600 $AUTHFILE
  fi
  echo $SSHKEY | sudo -i -u $AZUREUSER tee -a $AUTHFILE
else
  echo "no valid key data"
fi

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
  # ensure the host ip can resolve
  networkHealthy=1
  for i in {1..120}; do
    hostname -i
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      networkHealthy=0
      echo "the network is healthy"
      break
    fi
    sleep 1
  done
  if [ $networkHealthy -ne 0 ]
  then
    echo "the network is not healthy, cannot resolve ip address, aborting install"
    ifconfig
    ip a
    exit 2
  fi
}
ensureAzureNetwork
HOSTADDR=`hostname -i`

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

    IPADDR=`getent hosts ${MASTERPREFIX}${i} | awk '{ print $1 }'`
    zkhosts="${zkhosts}${IPADDR}:2181"
    # due to mesos team experience ip addresses are chosen over dns names
    #zkhosts="${zkhosts}${MASTERPREFIX}${i}:2181"
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

######################
# resolve self in DNS
######################

echo "$HOSTADDR $VMNAME" | sudo tee -a /etc/hosts

################
# Install Docker
################

echo "Installing and configuring docker and swarm"

time wget -qO- https://get.docker.com | sh

# Start Docker and listen on :2375 (no auth, but in vnet)
echo 'DOCKER_OPTS="-H unix:///var/run/docker.sock -H 0.0.0.0:2375"' | sudo tee /etc/default/docker
# the following insecure registry is for OMS
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
time sudo add-apt-repository -y ppa:openjdk-r/ppa
time sudo apt-get -y update
time sudo apt-get -y install openjdk-8-jre-headless
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
    IPADDR=`getent hosts ${MASTERPREFIX}${i} | awk '{ print $1 }'`
    echo "server.${i}=${IPADDR}:2888:3888" | sudo tee -a /etc/zookeeper/conf/zoo.cfg
    # due to mesos team experience ip addresses are chosen over dns names
    #echo "server.${i}=${MASTERPREFIX}${i}:2888:3888" | sudo tee -a /etc/zookeeper/conf/zoo.cfg
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
  # enable marathon to failover tasks to other nodes immediately
  echo 0 | sudo tee /etc/marathon/conf/failover_timeout
  #echo false | sudo tee /etc/marathon/conf/checkpoint
fi

#########################################
# Configure Mesos Master and Frameworks
#########################################
if ismaster ; then
  # Download and install mesos-dns
  sudo mkdir -p /usr/local/mesos-dns
  sudo wget https://github.com/mesosphere/mesos-dns/releases/download/v0.2.0/mesos-dns-v0.2.0-linux-amd64.tgz
  sudo tar zxvf mesos-dns-v0.2.0-linux-amd64.tgz
  sudo mv mesos-dns-v0.2.0-linux-amd64 /usr/local/mesos-dns/mesos-dns
  RESOLVER=`cat /etc/resolv.conf | grep nameserver | tail -n 1 | awk '{print $2}'`

  echo "
{
  \"zk\": \"zk://127.0.0.1:2181/mesos\",
  \"refreshSeconds\": 1,
  \"ttl\": 0,
  \"domain\": \"mesos\",
  \"port\": 53,
  \"timeout\": 1,
  \"listener\": \"0.0.0.0\",
  \"email\": \"root.mesos-dns.mesos\",
  \"resolvers\": [\"$RESOLVER\"]
}
" > mesos-dns.json
  sudo mv mesos-dns.json /usr/local/mesos-dns/mesos-dns.json

  echo "
description \"mesos dns\"

# Start just after the System-V jobs (rc) to ensure networking and zookeeper
# are started. This is as simple as possible to ensure compatibility with
# Ubuntu, Debian, CentOS, and RHEL distros. See:
# http://upstart.ubuntu.com/cookbook/#standard-idioms
start on stopped rc RUNLEVEL=[2345]
respawn

exec /usr/local/mesos-dns/mesos-dns -config /usr/local/mesos-dns/mesos-dns.json" > mesos-dns.conf
  sudo mv mesos-dns.conf /etc/init
  sudo service mesos-dns start
fi


#########################
# Configure Mesos Agent
#########################
if isagent ; then
  # Add docker containerizer
  echo "docker,mesos" | sudo tee /etc/mesos-slave/containerizers
  # Add resources configuration
  if ismaster ; then
    echo "ports:[1-21,23-4399,4401-5049,5052-8079,8081-32000]" | sudo tee /etc/mesos-slave/resources
  else
    echo "ports:[1-21,23-5050,5052-32000]" | sudo tee /etc/mesos-slave/resources
  fi
  hostname -i | sudo tee /etc/mesos-slave/ip
  hostname | sudo tee /etc/mesos-slave/hostname

  # Add mesos-dns IP addresses at the top of resolv.conf
  RESOLV_TMP=resolv.conf.temp
  rm -f $RESOLV_TMP
  for i in `seq $MASTERCOUNT` ; do
      echo nameserver `getent hosts ${MASTERPREFIX}${i} | awk '{ print $1 }'` >> $RESOLV_TMP
  done

  cat /etc/resolv.conf >> $RESOLV_TMP
  mv $RESOLV_TMP /etc/resolv.conf
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
if ismaster && [ "$SWARMENABLED" == "true" ] ; then
  echo "starting docker swarm:$SWARM_VERSION"
  echo "sleep to give master time to come up"
  sleep 10
  echo sudo docker run -d -e SWARM_MESOS_USER=root \
      --restart=always \
      -p 2376:2375 -p 3375:3375 swarm:$SWARM_VERSION manage \
      -c mesos-experimental \
      --cluster-opt mesos.address=0.0.0.0 \
      --cluster-opt mesos.port=3375 $zkmesosconfig
  sudo docker run -d -e SWARM_MESOS_USER=root \
      --restart=always \
      -p 2376:2375 -p 3375:3375 swarm:$SWARM_VERSION manage \
      -c mesos-experimental \
      --cluster-opt mesos.address=0.0.0.0 \
      --cluster-opt mesos.port=3375 $zkmesosconfig
  sudo docker ps
  echo "completed starting docker swarm"
fi
echo "processes at end of script"
ps ax
echo "Finished installing and configuring docker and swarm"
date
echo "completed mesos cluster configuration"
