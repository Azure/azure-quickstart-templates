wget https://raw.githubusercontent.com/AlsidOfficial/azure-quickstart-templates/alsid-ARM/alsid-syslog-proxy/rsyslog.conf

mv rsyslog.conf /etc/

echo $WORKSPACE_ID $PRIMARYKEY

wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh && sh onboard_agent.sh -w $WORKSPACE_ID -s $PRIMARYKEY -d opinsights.azure.com

service rsyslog restart
