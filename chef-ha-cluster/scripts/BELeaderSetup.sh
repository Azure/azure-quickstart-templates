# Primary BE setup
apt-get install -y apt-transport-https
wget -qO - https://downloads.chef.io/packages-chef-io-public.key | sudo apt-key add -
echo "deb https://packages.chef.io/current-apt trusty main" > /etc/apt/sources.list.d/chef-current.list

apt-get update
apt-get install -y chef-backend

cat > /etc/chef-backend/chef-backend.rb <<EOF
publish_address '10.0.0.10'

etcd.heartbeat_interval = 500
etcd.election_timeout = 5000
etcd.snapshot_count = 5000
postgresql.log_min_duration_statement = 500
elasticsearch.heap_size = 3500
EOF

chef-backend-ctl create-cluster --accept-license --yes --quiet --verbose
curl --upload-file /etc/chef-backend/chef-backend-secrets.json "$1/chef-backend-secrets.json$2" --header "x-ms-blob-type: BlockBlob"
chef-backend-ctl gen-server-config fe0 -f chef-server.rb.fe0
curl --upload-file chef-server.rb.fe0 "$1/chef-server.rb.fe0$2" --header "x-ms-blob-type: BlockBlob"
chef-backend-ctl gen-server-config fe1 -f chef-server.rb.fe1
curl --upload-file chef-server.rb.fe1 "$1/chef-server.rb.fe1$2" --header "x-ms-blob-type: BlockBlob"
chef-backend-ctl gen-server-config fe2 -f chef-server.rb.fe2
curl --upload-file chef-server.rb.fe2 "$1/chef-server.rb.fe2$2" --header "x-ms-blob-type: BlockBlob"
