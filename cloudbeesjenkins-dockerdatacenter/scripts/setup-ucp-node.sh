# We need four params: (1) PASSWORD (2) MASTERFQDN (3) MASTERPRIVATEIP (4) SLEEP

echo $(date) " - Starting Script"

PASSWORD=$1
MASTERFQDN=$2
MASTERPRIVATEIP=$3
SLEEP=$4

# Implement delay timer to stagger joining of Agent Nodes to cluster

echo $(date) "Sleeping for $SLEEP"
sleep $SLEEP

# Retrieve Fingerprint from Master Controller

curl --insecure https://$MASTERFQDN/ca > ca.pem

FPRINT=$(openssl x509 -in ca.pem -noout -sha256 -fingerprint | awk -F= '{ print $2 }' )

echo $FPRINT

# Load the predownloaded Tar File

echo $(date) " - Loading docker install Tar"

docker load < /opt/ucp/ucp-1.1.2_dtr-2.0.2.tar.gz

# Start installation of UCP and join agent Nodes to cluster

echo $(date) " - Loading complete.  Starting UCP Install of agent node"

docker run --rm -i \
    --name ucp \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e UCP_ADMIN_USER=admin \
    -e UCP_ADMIN_PASSWORD=$PASSWORD \
    docker/ucp:1.1.2 \
    join --san $MASTERFQDN --fresh-install --url https://${MASTERFQDN}:443 --fingerprint "${FPRINT}"

if [ $? -eq 0 ]
then
 echo $(date) " - UCP installed and started on the agent node"
else
 echo $(date) " -- UCP installation failed on agent node"
fi

# Configure NginX

echo $(date) " - Initiating NginX configuration on the agent node"

docker run -d \
--label interlock.ext.name=nginx \
--restart=always \
-p 80:80 \
-p 443:443 \
nginx \
nginx -g "daemon off;" -c /etc/nginx/nginx.conf

if [ $? -eq 0 ]
then
 echo $(date) " - NginX Install complete"
else
 echo $(date) " -- NginX Install failed"
fi
