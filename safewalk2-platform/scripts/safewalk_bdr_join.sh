#!/bin/bash

pushd /home/safewalk/safewalk_server/sources
bin/bdr_accept_node $@
bin/bdr_join_node $1 $2
service postgresql restart

psql safewalk-server -U postgres -h $2 -c "UPDATE  bdr.bdr_nodes SET node_status='r' WHERE node_status='c'"
psql safewalk-server -U postgres -h $2 -c "SELECT bdr.bdr_connections_changed()"
bash bin/update_fs_secrets_from_db
popd
