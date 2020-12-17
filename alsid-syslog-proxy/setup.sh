wget https://raw.githubusercontent.com/AlsidOfficial/azure-quickstart-templates/alsid-ARM/alsid-syslog-proxy/rsyslog.conf

mv rsyslog.conf /etc/

systemctl restart rsyslog
