WORKSPACE_ID=$1
PRIMARYKEY=$2
ARTIFACTS_LOCATION=$3
DNS_NAME=$4

wget $ARTIFACTS_LOCATION/rsyslog.conf

mv rsyslog.conf /etc/

echo $WORKSPACE_ID $PRIMARYKEY

wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh && sh onboard_agent.sh -w $WORKSPACE_ID -s $PRIMARYKEY -d opinsights.azure.com

apt install snapd

snap install core
snap refresh core

snap install --classic certbot

ln -s /snap/bin/certbot /usr/bin/certbot

sudo certbot certonly --standalone --register-unsafely-without-email --domain $DNS_NAME

service rsyslog restart
