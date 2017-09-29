#!/bin/bash

HOST=$1

source /home/safewalk/safewalk-server-venv/bin/activate
pushd /home/safewalk/safewalk_server
django-admin.py shell --settings=gaia_server.settings<<EOF
from core.models import OrganizationIdentity
o = OrganizationIdentity.objects.get()
o.gaia_web_url='https://$HOST/admin'
o.save()
EOF
service memcached restart
popd
deactivate

