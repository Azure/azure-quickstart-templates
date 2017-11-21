#!/bin/bash

my_dir=`dirname $0`
bash $my_dir/safewalk_bdr_accept_subnet.sh $2

pushd /home/safewalk/safewalk_server/sources
bin/bdr_create_group $1
service postgresql restart
popd
