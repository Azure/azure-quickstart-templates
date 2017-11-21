#!/bin/bash -x

source /home/safewalk/safewalk-server-venv/bin/activate
pushd /home/safewalk/safewalk_server
django-admin.py create_gateway "$@" --settings=gaia_server.settings
popd
deactivate
