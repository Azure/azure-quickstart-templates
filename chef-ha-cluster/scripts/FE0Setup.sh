# First FE
#wget https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_12.8.0-1_amd64.deb
#dpkg -i chef-server-core_12.8.0-1_amd64.deb
apt-get install -y apt-transport-https
wget -qO - https://downloads.chef.io/packages-chef-io-public.key | sudo apt-key add -
echo "deb https://packages.chef.io/stable-apt trusty main" > /etc/apt/sources.list.d/chef-stable.list
apt-get update
apt-get install -y chef-server-core chef-manage
curl -o /etc/opscode/chef-server.rb "$1/chef-server.rb.fe0$2"
chef-server-ctl reconfigure
curl --upload-file /etc/opscode/private-chef-secrets.json "$1/private-chef-secrets.json$2" --header "x-ms-blob-type: BlockBlob"
curl --upload-file /etc/opscode/webui_priv.pem "$1/webui_priv.pem$2" --header "x-ms-blob-type: BlockBlob"
curl --upload-file /etc/opscode/webui_pub.pem "$1/webui_pub.pem$2" --header "x-ms-blob-type: BlockBlob"
curl --upload-file /etc/opscode/pivotal.pem "$1/pivotal.pem$2" --header "x-ms-blob-type: BlockBlob"
curl --upload-file /var/opt/opscode/upgrades/migration-level "$1/migration-level$2" --header "x-ms-blob-type: BlockBlob"
sudo chef-server-ctl install chef-manage
sudo chef-server-ctl reconfigure
sudo chef-manage-ctl reconfigure --accept-license