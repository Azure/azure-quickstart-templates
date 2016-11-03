# Other FEs
#wget https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_12.8.0-1_amd64.deb
#dpkg -i chef-server-core_12.8.0-1_amd64.deb
apt-get install -y apt-transport-https
wget -qO - https://downloads.chef.io/packages-chef-io-public.key | sudo apt-key add -
echo "deb https://packages.chef.io/stable-apt trusty main" > /etc/apt/sources.list.d/chef-stable.list
apt-get update
apt-get install -y chef-server-core chef-manage
curl -o /etc/opscode/chef-server.rb "$1/chef-server.rb.`hostname`$2"
curl -o /etc/opscode/private-chef-secrets.json "$1/private-chef-secrets.json$2" 
curl -o /etc/opscode/webui_priv.pem "$1/webui_priv.pem$2" 
curl -o /etc/opscode/webui_pub.pem "$1/webui_pub.pem$2" 
curl -o /etc/opscode/pivotal.pem "$1/pivotal.pem$2" 
mkdir -p /var/opt/opscode/upgrades/
curl -o /var/opt/opscode/upgrades/migration-level "$1/migration-level$2" 
touch /var/opt/opscode/bootstrapped
chef-server-ctl reconfigure 
sudo chef-server-ctl install chef-manage
sudo chef-server-ctl reconfigure
sudo chef-manage-ctl reconfigure --accept-license