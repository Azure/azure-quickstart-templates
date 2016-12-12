# We need four params: (1) PASSWORD (2) MASTERFQDN (3) REPLICA_ID (4) MASTERPRIVATEIP (5) DTRNODE (6) SLEEP

echo $(date) " - Starting Script"

USER=admin
PASSWORD=$1
MASTERFQDN=$2
UCP_URL=https://$4
UCP_NODE=$(hostname)
REPLICA_ID=$3
MASTERPRIVATEIP=$4
DTRNODE=$5
SLEEP= $6

# Implement delay timer to stagger joining of Agent Nodes to cluster

echo $(date) "Sleeping for $SLEEP"
sleep $SLEEP

# Retrieve Fingerprint from Master Controller

curl --insecure https://$MASTERFQDN/ca > ca.pem

FPRINT=$(openssl x509 -in ca.pem -noout -sha256 -fingerprint | awk -F= '{ print $2 }' )

echo $FPRINT

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
 echo $(date) " - UCP installed and started on the agent node to be used for DTR replica"
else
 echo $(date) " -- UCP installation failed on DTR node"
fi

