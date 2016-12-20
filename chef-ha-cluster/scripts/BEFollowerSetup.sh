# BE Secondary
curl -o chef-backend-secrets.json "$1/chef-backend-secrets.json$2"
#wget https://packages.chef.io/stable/ubuntu/14.04/chef-backend_1.0.9-1_amd64.deb
#dpkg -i chef-backend_1.0.9-1_amd64.deb
apt-get install -y apt-transport-https
wget -qO - https://downloads.chef.io/packages-chef-io-public.key | sudo apt-key add -
echo "deb https://packages.chef.io/stable-apt trusty main" > /etc/apt/sources.list.d/chef-stable.list
apt-get update
apt-get install -y chef-backend
chef-backend-ctl join-cluster 10.0.0.10 -p `ip addr | grep "inet 10" | tr -s ' '  ' ' | cut -d " " -f3 | cut -d"/" -f1` -s chef-backend-secrets.json --accept-license --yes --verbose --quiet
