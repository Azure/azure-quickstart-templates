
#!/bin/bash

# You must be root to run this script
if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

wget -O /opt/trend-micro-deep-security-for-splunk_152.tgz https://trendmicrop2p.blob.core.windows.net/trendmicropushtopilot/trend-micro-deep-security-for-splunk_152.tgz 

/opt/splunk/bin/splunk install app /opt/trend-micro-deep-security-for-splunk_152.tgz -update 1 -auth admin:$1

mkdir /opt/splunk/etc/apps/TrendMicroDeepSecurity/local

echo -e "\n[udp://${2}] \nconnection_host = ip \nsourcetype = deepsecurity" >> /opt/splunk/etc/apps/TrendMicroDeepSecurity/local/inputs.conf

/opt/splunk/bin/splunk restart