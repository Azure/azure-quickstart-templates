#!/bin/bash
# $1 = Root URL
# $2 = Admin address
# $3 = Open permissions

apt-get update
apt-get install -y git

cd /opt
git clone https://github.com/openchain/docker.git openchain
cd openchain
cp templates/docker-compose-proxy.yml docker-compose.yml
cp templates/nginx.conf nginx/nginx.conf
mkdir data
cp templates/config.json data/config.json

sed -i "s#\"root_url\": \"\"#\"root_url\": \"$1\"#g" data/config.json
sed -i "s#\"admin_addresses\": \[#\"admin_addresses\": [ \"$2\" #g" data/config.json

sed -i "s#\"allow_p2pkh_accounts\": true#\"allow_p2pkh_accounts\": $3#g" data/config.json
sed -i "s#\"allow_third_party_assets\": true#\"allow_third_party_assets\": $3#g" data/config.json

docker-compose up -d
