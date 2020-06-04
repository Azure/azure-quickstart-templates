#!/bin/bash

/opt/safekit/safekit shutdown
/opt/safekit/safekit uninstall

echo "Install SafeKit"
yum -y localinstall $1
