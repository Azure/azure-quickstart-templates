#!/bin/bash

pushd /home/safewalk/safewalk_server/sources
bin/bdr_accept_node $@
sed -i "s|sleep 10|sleep 60|" bin/bdr_join_node
bin/bdr_join_node $1 $2
service postgresql restart
popd
