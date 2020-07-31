#!/bin/bash

sudo -u $1 bash <<EOF
/sasshare/depot/setup.sh -quiet -loglevel 2 -responsefile $2
exit
EOF
