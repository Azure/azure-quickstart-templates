# We need four params: (1) PASSWORD (2) MASTERFQDN (3) MASTERPRIVATEIP (4) SLEEP

echo $(date) " - Starting Script"

PASSWORD=$1
MASTERFQDN=$2
MASTERPRIVATEIP=$3
SLEEP=$4

# Implement delay timer to stagger joining of Controller replicas to cluster

echo $(date) "Sleeping for $SLEEP"
sleep $SLEEP



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

# Retrieve Fingerprint from Master Controller
curl --insecure https://ucpclus0-ucpctrl/ca > ca.pem
FPRINT=$(openssl x509 -in ca.pem -noout -sha256 -fingerprint | awk -F= '{ print $2 }' )
echo $FPRINT

# Load the downloaded Tar File

#echo $(date) " - Loading docker install Tar"
cd /opt/ucp && wget https://packages.docker.com/caas/ucp-2.0.0-beta1_dtr-2.1.0-beta1.tar.gz
docker load < ucp-2.0.0-beta1_dtr-2.1.0-beta1.tar.gz

# Start installation of UCP and join Controller replica to master Controller

docker run --rm -i \
    --name ucp \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e UCP_ADMIN_USER=admin \
    -e UCP_ADMIN_PASSWORD=$PASSWORD \
    docker/ucp:2.0.0-beta1 \
    join --replica --san ucpclus0-ucpctrl --url https://ucpclus0-ucpctrl --fingerprint "${FPRINT}"

if [ $? -eq 0 ]
then
echo $(date) " - UCP installed and started on the master(replica) Controller"
else
 echo $(date) " -- UCP installation failed"
fi


echo $(date) " - Staring Swarm Join as Manager to Leader UCP Controller"
apt-get -y update && apt-get install -y curl jq
# Create an environment variable with the user security token
AUTHTOKEN=$(curl -sk -d '{"username":"admin","password":"'"$PASSWORD"'"}' https://ucpclus0-ucpctrl/auth/login | jq -r .auth_token)
echo "$AUTHTOKEN"
# Download the client certificate bundle
curl -k -H "Authorization: Bearer ${AUTHTOKEN}" https://ucpclus0-ucpctrl/api/clientbundle -o bundle.zip
unzip bundle.zip && chmod 755 env.sh && source env.sh
docker swarm join-token manager|sed '1d'|sed '1d'|sed '$ d'>swarmjoin.sh
unset DOCKER_TLS_VERIFY
unset DOCKER_CERT_PATH
unset DOCKER_HOST
chmod 755 swarmjoin.sh
source swarmjoin.sh
