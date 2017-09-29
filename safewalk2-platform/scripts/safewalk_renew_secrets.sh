#!/bin/bash -ex

pushd /home/safewalk/safewalk_server/sources
bin/safewalk_renew_secrets.sh force
bin/update_fs_secrets_from_db
popd
