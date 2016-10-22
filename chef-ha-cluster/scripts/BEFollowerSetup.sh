# BE Secondary
curl -o chef-backend-secrets.json "$1/chef-backend-secrets.json$2"

apt-get install -y apt-transport-https
wget -qO - https://downloads.chef.io/packages-chef-io-public.key | sudo apt-key add -
echo "deb https://packages.chef.io/current-apt trusty main" > /etc/apt/sources.list.d/chef-current.list


apt-get update
apt-get install -y chef-backend

chef-backend-ctl join-cluster 10.0.0.10 -p `ip addr | grep "inet 10" | tr -s ' '  ' ' | cut -d " " -f3 | cut -d"/" -f1` -s chef-backend-secrets.json --accept-license --yes --verbose --quiet

sleep 10

cat >> /etc/chef-backend/chef-backend.rb <<EOF
etcd.heartbeat_interval = 500
etcd.election_timeout = 5000
etcd.snapshot_count = 5000
postgresql.log_min_duration_statement = 500
elasticsearch.heap_size = 3500
EOF

chef-backend-ctl reconfigure
