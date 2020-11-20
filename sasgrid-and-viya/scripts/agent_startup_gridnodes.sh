#!/bin/bash
set -x
echo "*** Phase 3 SAS EnvManagerAgents Start Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"

## Function for error handling
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

folder=`hostname -s`
#Start the Env Manager Agent on Grid Control Server
su - sasinst -c "/opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/grid/$folder/agent-5.8.0-EE/bin/hq-agent.sh start"

echo "*** Phase 3 SAS EnvManagerAgents Start Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"