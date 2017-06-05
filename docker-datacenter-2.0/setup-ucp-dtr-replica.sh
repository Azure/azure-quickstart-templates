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

# System Update and docker version update
DEBIAN_FRONTEND=noninteractive apt-get -y update
apt-get install -y apt-transport-https ca-certificates
#apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
#echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' >> /etc/apt/sources.list.d/docker.list
curl -s 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | apt-key add --import
echo 'deb https://packages.docker.com/1.12/apt/repo ubuntu-trusty main' >> /etc/apt/sources.list.d/docker.list
apt-cache policy docker-engine
DEBIAN_FRONTEND=noninteractive apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

# Implement delay timer to stagger joining of Agent Nodes to cluster
echo $(date) " - Loading docker install Tar"
cd /opt/ucp && wget https://packages.docker.com/caas/ucp-2.0.0-beta1_dtr-2.1.0-beta1.tar.gz
#cd /opt/ucp && wget https://packages.docker.com/caas/ucp-1.1.4_dtr-2.0.3.tar.gz
#docker load < /opt/ucp/ucp-1.1.2_dtr-2.0.2.tar.gz
#docker load < /opt/ucp/ucp-1.1.4_dtr-2.0.3.tar.gz
docker load < ucp-2.0.0-beta1_dtr-2.1.0-beta1.tar.gz

# Start installation of UCP with master Controller

echo $(date) " - Loading complete.  Starting UCP Install"


installbundle ()
{

echo $(date) "Sleeping for $SLEEP"
sleep $SLEEP
echo $(date) " - Staring Swarm Join as worker UCP Controller"
apt-get -y update && apt-get install -y curl jq
# Create an environment variable with the user security token
AUTHTOKEN=$(curl -sk -d '{"username":"admin","password":"'"$PASSWORD"'"}' https://ucpclus0-ucpctrl/auth/login | jq -r .auth_token)
echo "$AUTHTOKEN"
# Download the client certificate bundle
curl -k -H "Authorization: Bearer ${AUTHTOKEN}" https://ucpclus0-ucpctrl/api/clientbundle -o bundle.zip
unzip -o bundle.zip && chmod 755 env.sh && source env.sh
}
joinucp() {
installbundle;
docker swarm join-token worker|sed '1d'|sed '1d'|sed '$ d'>swarmjoin.sh
unset DOCKER_TLS_VERIFY
unset DOCKER_CERT_PATH
unset DOCKER_HOST
chmod 755 swarmjoin.sh
source swarmjoin.sh
}
installdtr() {
installbundle;
docker run --rm -i \
  dockerhubenterprise/dtr:2.1.0-beta1 install \
  --ucp-node $UCP_NODE \
  --ucp-insecure-tls \
  --dtr-external-url $DTR_PUBLIC_URL  \
  --ucp-url https://ucpclus0-ucpctrl \
  --ucp-username admin --ucp-password $PASSWORD
  }
joinucp;
#echo $(date) "Sleeping for 200"
#sleep 200;
# Install DTR
#installdtr;

if [ $? -eq 0 ]
then
 echo $(date) " - UCP installed and started on the agent node to be used for DTR replica"
else
 echo $(date) " -- UCP installation failed on DTR node"
fi
