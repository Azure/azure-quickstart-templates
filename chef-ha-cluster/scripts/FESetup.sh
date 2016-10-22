# Other FEs
#wget https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_12.8.0-1_amd64.deb
#dpkg -i chef-server-core_12.8.0-1_amd64.deb
apt-get install -y apt-transport-https
wget -qO - https://downloads.chef.io/packages-chef-io-public.key | sudo apt-key add -
echo "deb https://packages.chef.io/stable-apt trusty main" > /etc/apt/sources.list.d/chef-stable.list
apt-get update
apt-get install -y chef-server-core chef-manage
curl -o /etc/opscode/chef-server.rb "$1/chef-server.rb.`hostname`$2"

cat >> /etc/opscode/chef-server.rb <<EOF
opscode_erchef['s3_url_expiry_window_size'] = '100%'
license['nodes'] = 999999
oc_chef_authz['http_init_count'] = 100
oc_chef_authz['http_max_count'] = 100
oc_chef_authz['http_queue_max'] = 200
oc_bifrost['db_pool_size'] = 20
oc_bifrost['db_pool_queue_max'] = 40
oc_bifrost['db_pooler_timeout'] = 2000
opscode_erchef['depsolver_worker_count'] = 4
opscode_erchef['depsolver_timeout'] = 20000
opscode_erchef['db_pool_size'] = 20
opscode_erchef['db_pool_queue_max'] = 40
opscode_erchef['db_pooler_timeout'] = 2000
opscode_erchef['authz_pooler_timeout'] = 2000
EOF

curl -o /etc/opscode/private-chef-secrets.json "$1/private-chef-secrets.json$2"
curl -o /etc/opscode/webui_priv.pem "$1/webui_priv.pem$2"
curl -o /etc/opscode/webui_pub.pem "$1/webui_pub.pem$2"
curl -o /etc/opscode/pivotal.pem "$1/pivotal.pem$2"
mkdir -p /var/opt/opscode/upgrades/
curl -o /var/opt/opscode/upgrades/migration-level "$1/migration-level$2"
touch /var/opt/opscode/bootstrapped
chef-server-ctl reconfigure --accept-license
sudo chef-server-ctl install chef-manage
sudo chef-server-ctl reconfigure
sudo chef-manage-ctl reconfigure --accept-license
