#!/bin/bash

# print commands and arguments as they are executed
set -x

echo 'hello'

echo "starting ubuntu tensorflow install on pid $$"
date
ps axjf

#############
# Parameters
#############

AZUREUSER=$1
HOMEDIR="/home/$AZUREUSER"
VMNAME=`hostname`
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "vmname: $VMNAME"

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

time  apt-get -y update

echo 'system updated'

pip3Install() {
    time  apt install -y python3-pip 
}
pip3Install

echo 'pip3 installed'

tensorflowInstall() {
    time pip3 install tensorflow
    time  apt-get install -y protobuf-compiler python-pil python-lxml python-tk
    time  pip3 install pillow
    time  pip3 install lxml
    time  pip3 install jupyter
    time  apt-get install -y openjdk-8-jdk
    time  apt-get install -y python3-numpy python3-dev python3-pip python3-wheel
    time pip3 install --no-binary --no-cache-dir Cython
}

echo 'tensorflow installed'

tensorFlow="$HOMEDIR/.local/lib/python3.6/site-packages/tensorflow"

copyModels() {
    time git clone https://github.com/tensorflow/models.git
    time  cp -r models $tensorFlow/
}

copyModels

echo 'models copied'

echo 'using forked branch of cocoapi to support python3'

installCocoAPI() {
    cd $HOMEDIR
    git clone https://github.com/JayDevOps/cocoapi.git
    cd cocoapi/PythonAPI/
    time  git checkout python3X-compat
    time  make -w
    time  make install -w
    cd $HOMEDIR/cocoapi/PythonAPI/
    cp -r pycocotools $tensorFlow/models/research/
    cd $tensorFlow/models/research/
    protoc object_detection/protos/*.proto --python_out=.
    ls $HOMEDIR/.bashrc | while read file; do
        (echo 'export PYTHONPATH=$PYTHONPATH':`pwd`:`pwd`/slim; cat ${file} ) > ${file}.new && mv ${file}.new ${file};
        done
     source $HOMEDIR/.bashrc
}
installCocoAPI
echo 'cocoAPI install completed'
