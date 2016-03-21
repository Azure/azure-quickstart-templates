#! /bin/sh

sed -i "2i$1 $2" /etc/hosts
sed -i "2i$1 $3" /etc/hosts
curl -k https://$3:8140/packages/current/install.bash | sudo bash