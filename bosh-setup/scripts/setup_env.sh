#!/usr/bin/env bash

source utils.sh

echo "Start to update package lists from repositories..."
retryop "apt-get update"

echo "Start to install prerequisites..." 
retryop "apt-get -y install build-essential ruby2.0 ruby2.0-dev libxml2-dev libsqlite3-dev libxslt1-dev libpq-dev libmysqlclient-dev zlibc zlib1g-dev openssl libxslt-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev sqlite3 libffi-dev python-dev python-pip jq"

set -e

custom_data_file="/var/lib/cloud/instance/user-data.txt"
settings=$(cat ${custom_data_file})
tenant_id=$1
client_id=$2
client_secret=$3

function get_setting() {
  key=$1
  local value=$(echo $settings | jq ".$key" -r)
  echo $value
}

function install_bosh_cli_and_init() {
  echo "Start to update udpate Ruby 1.9 to 2.0 ..."
  # Update Ruby 1.9 to 2.0
  sudo rm /usr/bin/ruby /usr/bin/gem /usr/bin/irb /usr/bin/rdoc /usr/bin/erb
  sudo ln -s /usr/bin/ruby2.0 /usr/bin/ruby
  sudo ln -s /usr/bin/gem2.0 /usr/bin/gem
  sudo ln -s /usr/bin/irb2.0 /usr/bin/irb
  sudo ln -s /usr/bin/rdoc2.0 /usr/bin/rdoc
  sudo ln -s /usr/bin/erb2.0 /usr/bin/erb

  set +e

  environment=$1
  if [ "$environment" == "AzureChinaCloud" ]; then
    sudo gem sources --remove https://rubygems.org/
    sudo gem sources --add https://ruby.taobao.org/
    sudo gem sources --add https://gems.ruby-china.org/
  fi

  set -e

  gem sources -l
  sudo gem update --system
  sudo gem pristine --all

  echo "Start to install bosh_cli..."
  sudo gem install bosh_cli -v 1.3169.0 --no-ri --no-rdoc

  echo "Start to install bosh-init..."
  bosh_init_url=$2
  wget $bosh_init_url
  chmod +x ./bosh-init-*
  sudo mv ./bosh-init-* /usr/local/bin/bosh-init
}

environment=$(get_setting ENVIRONMENT)

set +e

echo "Start to install python packages..."
pkg_list="pip==1.5.4 setuptools==32.3.1 msrest==0.4.4 msrestazure==0.4.4 requests==2.11.1 azure==2.0.0rc1 netaddr==0.7.18 PyGreSQL==5.0.2 ruamel.yaml==0.15.18"
if [ "$environment" = "AzureChinaCloud" ]; then
  for pkg in $pkg_list; do
    retryop "pip install $pkg --index-url https://mirror.azure.cn/pypi/simple/ --default-timeout=60"
  done
else
  for pkg in $pkg_list; do
    retryop "pip install $pkg"
  done
fi

set -e

# Install Ruby before other operations to make sure Ruby 2.0 is used
bosh_init_url=$(get_setting BOSH_INIT_URL)
install_bosh_cli_and_init $environment $bosh_init_url

username=$(get_setting ADMIN_USER_NAME)
home_dir="/home/$username"

echo "Start to generate SSH key pair for BOSH..."
bosh_key="bosh"
ssh-keygen -t rsa -f $bosh_key -P "" -C ""
chmod 400 $bosh_key
cp $bosh_key $home_dir
cp "$bosh_key.pub" $home_dir

echo "Start to run setup_env.py..."
python setup_env.py ${tenant_id} ${client_id} ${client_secret} ${custom_data_file}

echo "Start to replace cert varialbes for manifests..."
chmod +x replace_certs.sh
./replace_certs.sh

# For backward compatibility
sed -i "s/CLOUD_FOUNDRY_PUBLIC_IP/cf-ip/g" settings
cp settings $home_dir
cp bosh.yml $home_dir

chmod +x deploy_bosh.sh
cp deploy_bosh.sh $home_dir

chmod +x deploy_cloudfoundry.sh
cp deploy_cloudfoundry.sh $home_dir
cp utils.sh $home_dir

example_manifests="$home_dir/example_manifests"
mkdir -p $example_manifests
if [ "$environment" = "AzureStack" ]; then
  cp multiple-vm-cf.yml $example_manifests
  chmod 644 $example_manifests/multiple-vm-cf.yml
else
  cp single-vm-cf.yml $example_manifests 
  cp multiple-vm-cf.yml $example_manifests
  chmod 644 $example_manifests/single-vm-cf.yml
  chmod 644 $example_manifests/multiple-vm-cf.yml
fi

cp cf* $home_dir
chown -R $username $home_dir

auto_deploy_bosh=$(get_setting AUTO_DEPLOY_BOSH)
if [ "$auto_deploy_bosh" != "enabled" ]; then
  echo "Finish"
  exit 0
fi

echo "Start to run deploy_bosh.sh..."
su -c "./deploy_bosh.sh" - $username

if [ "$environment" = "AzureChinaCloud" ]; then 
  echo "Start to inject some xip.io records to PowerDNS on BOSH VM..." 
  python inject_xip_io_records.py "$home_dir/bosh.yml" "$home_dir/settings" 
fi 

echo "Finish"
