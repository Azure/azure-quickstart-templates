#!/bin/sh

if [ ! -n $STREAM_URL ]
then
   echo "ERROR! STREAM_URL must be set!"
   exit 1
fi


curl -o /tmp/cribl-stream.tgz ${STREAM_URL}
tar xzf /tmp/cribl-stream.tgz --owner=cribl --group=cribl -C /opt
chown -R cribl:cribl /opt/cribl