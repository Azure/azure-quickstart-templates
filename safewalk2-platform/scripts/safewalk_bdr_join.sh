#!/bin/bash

bash $my_dir/safewalk_bdr_accept_subnet.sh $3

pushd /home/safewalk/safewalk_server/sources
sed -i "s|sleep 10|sleep 60|" bin/bdr_join_node
bin/bdr_join_node $1 $2
service postgresql restart
popd
