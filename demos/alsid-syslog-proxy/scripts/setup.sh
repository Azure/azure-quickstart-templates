WORKSPACE_ID=$1
PRIMARYKEY=$2
ARTIFACTS_LOCATION=$3
DNS_NAME=$4
SAS_TOKEN=$5

CERTS_PATH=/etc/letsencrypt/live/$DNS_NAME/


# Install required packages
apt update
apt install rsyslog-gnutls # For TLS support on rsyslog

apt install snapd # Recommended to install certbot
snap install core
snap refresh core
snap install --classic certbot # To generate TLS certificates


# Get rsyslog configuration
wget $ARTIFACTS_LOCATION/configs/rsyslog.conf$SAS_TOKEN

mv rsyslog.conf /etc/


# Install Sentinel agent
wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh && sh onboard_agent.sh -w $WORKSPACE_ID -s $PRIMARYKEY -d opinsights.azure.com


# Generate TLS certificates
ln -s /snap/bin/certbot /usr/bin/certbot

certbot certonly --standalone --register-unsafely-without-email -n --agree-tos --domain $DNS_NAME


# Move certificates in rsyslog config
cp $CERTS_PATH/cert.pem $CERTS_PATH/chain.pem $CERTS_PATH/privkey.pem /etc/rsyslog.d/


# Restart rsyslog service
service rsyslog restart
