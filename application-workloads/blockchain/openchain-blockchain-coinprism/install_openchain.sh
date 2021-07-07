#!/bin/bash
# $1 = Root URL
# $2 = Openchain version
# $3 = Admin address
# $4 = Open permissions

apt-get update
apt-get install -y git

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update

apt-get install -y docker-ce

curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

cd /opt
git clone https://github.com/openchain/docker.git openchain
cd openchain
git checkout v$2
cp templates/docker-compose-proxy.yml docker-compose.yml
cp templates/nginx.conf nginx/nginx.conf
mkdir data
cp templates/config.json data/config.json

sed -i "s#\"instance_seed\": \"\"#\"instance_seed\": \"$1\"#g" data/config.json
sed -i "s#\"admin_addresses\": \[#\"admin_addresses\": [ \"$3\" #g" data/config.json

sed -i "s#\"allow_p2pkh_accounts\": true#\"allow_p2pkh_accounts\": $4#g" data/config.json
sed -i "s#\"allow_third_party_assets\": true#\"allow_third_party_assets\": $4#g" data/config.json

docker-compose up -d
