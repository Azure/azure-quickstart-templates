#!/usr/bin/env bash

set -e

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

