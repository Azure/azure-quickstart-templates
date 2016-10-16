
echo $(date) " - Starting Script"

PASSWORD=$1
MASTERFQDN=$2

FILEURI=$3
MASTERPRIVATEIP=$4


#copy license key to /opt/ucp/ucp
cat > /opt/ucp/docker_subscription.lic <<EOF
'$FILEURI'
EOF

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

# removing a special character from subscription.lic
sed -i -- "s/'//g" /opt/ucp/docker_subscription.lic
sed -i -- "s/{/{\"/g" /opt/ucp/docker_subscription.lic
sed -i -- "s/}/\"}/g" /opt/ucp/docker_subscription.lic
sed -i -- "s/:/\":/g" /opt/ucp/docker_subscription.lic
sed -i -- "s/,\ /,\ \"/g" /opt/ucp/docker_subscription.lic   
#wget "$FILEURI" -O /opt/ucp/docker_subscription.lic

# Fix for Docker Daemon when cloning a base image
# rm  /etc/docker/key.json  
# service docker restart

# Load the downloaded Tar File

echo $(date) " - Loading docker install Tar"
cd /opt/ucp && wget https://packages.docker.com/caas/ucp-2.0.0-beta1_dtr-2.1.0-beta1.tar.gz
#cd /opt/ucp && wget https://packages.docker.com/caas/ucp-1.1.4_dtr-2.0.3.tar.gz
#docker load < /opt/ucp/ucp-1.1.2_dtr-2.0.2.tar.gz
#docker load < /opt/ucp/ucp-1.1.4_dtr-2.0.3.tar.gz
docker load < ucp-2.0.0-beta1_dtr-2.1.0-beta1.tar.gz

# Start installation of UCP with master Controller

echo $(date) " - Loading complete.  Starting UCP Install"

docker run --rm -i \
    --name ucp \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /opt/ucp/docker_subscription.lic:/docker_subscription.lic \
    -e UCP_ADMIN_PASSWORD=$PASSWORD \
    docker/ucp:2.0.0-beta1 \
    install -D --host-address eth0

if [ $? -eq 0 ]
then
 echo $(date) " - UCP installed and started on the master Controller"
else
 echo $(date) " -- UCP installation failed"
fi
