#!/bin/bash
rm /root/.ssh/known_hosts 

SWP_NAME=safewalk-accumulated-patch-2.4.18
SWP_DOWNLOAD_URL=https://download.altipeaksecurity.com/index.php/s/7qedA0vkkqFzVSe/download

pushd /home/safewalk/safewalk_server/sources
bin/safewalk_upgrade.sh $SWP_DOWNLOAD_URL $SWP_NAME
popd