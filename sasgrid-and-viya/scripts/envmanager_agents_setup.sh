#!/bin/bash
set -x
echo "*** Phase 5 SAS EnvManagerAgents Setup Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"

## Function for error handling
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

app_name=`facter application_name`
sas_role=`facter sas_role`
domain_name=`facter domain_name`

#Stop the Env Manager Agent on Grid Control Server
su - sasinst -c "/opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/agent-5.8.0-EE/bin/hq-agent.sh stop"

#Create directories and Copy the agent directory structure for all the grid nodes
count=`facter grid_nodes`
if [ $count == 0 ]; then
   echo "Single Master server"
else
   i=1
   while [ "$count" != "0" ] ; do
      #echo grid0$i.$Domain
      su - sasinst -c "mkdir -p /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/grid/${app_name}gridnode$i"
      su - sasinst -c "cp -pr /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/agent-5.8.0-EE /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/grid/${app_name}gridnode$i"
      su - sasinst -c "rm -rf /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/grid/${app_name}gridnode$i/agent-5.8.0-EE/data/*"
      su - sasinst -c "rm -rf /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/grid/${app_name}gridnode$i/agent-5.8.0-EE/log/*"
      su - sasinst -c "mv /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/grid/${app_name}gridnode$i/agent-5.8.0-EE/conf/agent.properties /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/grid/${app_name}gridnode$i/agent-5.8.0-EE/conf/agent.properties.orig"
      sed "s/^agent.setup.agentIP=.*/agent.setup.agentIP=${app_name}gridnode$i.$domain_name/" /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/grid/${app_name}gridnode$i/agent-5.8.0-EE/conf/agent.properties.orig > /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/grid/${app_name}gridnode$i/agent-5.8.0-EE/conf/agent.properties
      echo "" >> /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/grid/${app_name}gridnode$i/agent-5.8.0-EE/conf/agent.properties
      echo "# Include only Environment Manager plugins for SAS Grid nodes" >> /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/grid/${app_name}gridnode$i/agent-5.8.0-EE/conf/agent.properties
      echo "plugins.include=sas-servers,hqagent,sas-deploy-agent" >> /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/grid/${app_name}gridnode$i/agent-5.8.0-EE/conf/agent.properties
      su - sasinst -c "mv /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/grid/${app_name}gridnode$i/agent-5.8.0-EE/conf/sas.properties /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/grid/${app_name}gridnode$i/agent-5.8.0-EE/conf/sas.properties.orig"
      su - sasinst -c "ln -s /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/agent-5.8.0-EE/conf/sas.properties /opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/grid/${app_name}gridnode$i/agent-5.8.0-EE/conf/sas.properties"
	  i=$(($i+1))
      count=$(($count-1))
   done
fi

#Start the Env Manager Agent on Grid Control Server
su - sasinst -c "/opt/sas/grid/config/Lev1/Web/SASEnvironmentManager/agent-5.8.0-EE/bin/hq-agent.sh start"

echo "*** Phase 5 SAS EnvManagerAgents Setup Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"