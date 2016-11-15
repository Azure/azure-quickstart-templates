#!/usr/bin/env bash

source utils.sh

echo "Start to update package lists from repositories..."
retryop "apt-get update"

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
pkg_list="msrest msrestazure azure==2.0.0rc1 azure-storage netaddr"
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

username=$(get_setting ADMIN_USER_NAME)
home_dir="/home/$username"

echo "Start to generate SSH key pair for BOSH..."
bosh_key="bosh"
ssh-keygen -t rsa -f $bosh_key -P "" -C ""
chmod 400 $bosh_key
cp $bosh_key $home_dir
cp "$bosh_key.pub" $home_dir

echo "Start to generate SSL certificate for cloud foundry..."
chmod +x create_cert.sh
cf_key="cloudfoundry.key"
cf_cert="cloudfoundry.cert"
./create_cert.sh $cf_key $cf_cert

echo "Start to run setup_env.py..."
python setup_env.py ${tenant_id} ${client_id} ${client_secret} ${custom_data_file}

# For backward compatibility
sed -i "s/CLOUD_FOUNDRY_PUBLIC_IP/cf-ip/g" settings
cp settings $home_dir

echo "Start to specify params in bosh.yml..."
REPLACE_WITH_NATS_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9')
REPLACE_WITH_POSTGRES_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9')
REPLACE_WITH_REGISTRY_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9')
REPLACE_WITH_DIRECTOR_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9')
REPLACE_WITH_AGENT_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9')
REPLACE_WITH_ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9')
REPLACE_WITH_HM_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9')
REPLACE_WITH_MBUS_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9')
sed -i "s/REPLACE_WITH_NATS_PASSWORD/$REPLACE_WITH_NATS_PASSWORD/g" bosh.yml
sed -i "s/REPLACE_WITH_POSTGRES_PASSWORD/$REPLACE_WITH_POSTGRES_PASSWORD/g" bosh.yml
sed -i "s/REPLACE_WITH_REGISTRY_PASSWORD/$REPLACE_WITH_REGISTRY_PASSWORD/g" bosh.yml
sed -i "s/REPLACE_WITH_DIRECTOR_PASSWORD/$REPLACE_WITH_DIRECTOR_PASSWORD/g" bosh.yml
sed -i "s/REPLACE_WITH_AGENT_PASSWORD/$REPLACE_WITH_AGENT_PASSWORD/g" bosh.yml
sed -i "s/REPLACE_WITH_ADMIN_PASSWORD/$REPLACE_WITH_ADMIN_PASSWORD/g" bosh.yml
sed -i "s/REPLACE_WITH_HM_PASSWORD/$REPLACE_WITH_HM_PASSWORD/g" bosh.yml
sed -i "s/REPLACE_WITH_MBUS_PASSWORD/$REPLACE_WITH_MBUS_PASSWORD/g" bosh.yml
cp bosh.yml $home_dir

sed -i "s/REPLACE_WITH_ADMIN_PASSWORD/$REPLACE_WITH_ADMIN_PASSWORD/g" deploy_bosh.sh
chmod +x deploy_bosh.sh
cp deploy_bosh.sh $home_dir
echo $REPLACE_WITH_ADMIN_PASSWORD > "$home_dir/BOSH_DIRECTOR_ADMIN_PASSWORD"

chmod +x deploy_cloudfoundry.sh
cp deploy_cloudfoundry.sh $home_dir
cp utils.sh $home_dir
example_manifests="$home_dir/example_manifests"
mkdir -p $example_manifests
cp single-vm-cf.yml $example_manifests 
cp multiple-vm-cf.yml $example_manifests
chmod 644 $example_manifests/single-vm-cf.yml
chmod 644 $example_manifests/multiple-vm-cf.yml

cp cf* $home_dir
bosh_init_url=$(get_setting BOSH_INIT_URL)
install_bosh_cli_and_init $environment $bosh_init_url

chown -R $username $home_dir

auto_deploy_bosh=$(get_setting AUTO_DEPLOY_BOSH)
if [ "$auto_deploy_bosh" != "enabled" ]; then
  echo "Finish"
  exit 0
fi

echo "Start to run deploy_bosh.sh..."
su -c "./deploy_bosh.sh" - $username
echo "Finish"
