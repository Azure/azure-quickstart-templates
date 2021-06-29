#!/bin/bash

echo $*

# Start PowerShell config script
export SAFEKITCMD="/opt/safekit/safekit"
export SAFEVAR="/var/safekit"
export SAFEWEBCONF="/opt/safekit/web/conf"
export SAFEBASE="/opt/safekit"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/safekit/private/bin"
pwsh ./configCluster.ps1 -vmlist "$1" -publicipfmt "$2" -privateiplist "$3" -lblist "$4" -Passwd "$5"
