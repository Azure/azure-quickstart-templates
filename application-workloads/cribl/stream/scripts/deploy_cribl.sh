#!/bin/sh
export CRIBL_HOME=/opt/cribl
STREAM_URL=https://cdn.cribl.io/dl/latest-x64
buildShell=`curl -s  https://cdn.cribl.io/versions.json | jq -r '.version'`
version=${buildShell%-*}
echo $version
build=${buildShell##*-}
echo $build

if [ ! -n $STREAM_URL ]
then
   echo "ERROR! STREAM_URL must be set!"
   exit 1
fi

apt-get update 
apt-get install -y \
   git \
   gettext \
   jq 
mkdir -p /opt/cribl 
useradd cribl -d /home/cribl -m -G sudo
chown -R cribl:cribl /home/cribl
curl -o /tmp/cribl-stream.tgz ${STREAM_URL}
tar xzf /tmp/cribl-stream.tgz --owner=cribl --group=cribl -C /opt
chown -R cribl:cribl /opt/cribl