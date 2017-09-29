#!/bin/bash

pushd /home/safewalk/safewalk_server/sources
bin/bdr_accept_node $@
bin/bdr_create_group $1
service postgresql restart
popd
