#!/bin/sh
echo "Start to update package lists from repositories..."
sudo apt-get update

echo "Start to update install prerequisites..."
sudo apt-get install -y build-essential ruby ruby-dev libxml2-dev libsqlite3-dev libxslt1-dev libpq-dev libmysqlclient-dev zlibc zlib1g-dev openssl libxslt-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev sqlite3 libffi-dev

echo "Start to install bosh_cli..."
sudo gem install bosh_cli -v 1.3016.0 --no-ri --no-rdoc

echo "Start to install bosh-init..."
wget https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-0.0.51-linux-amd64
chmod +x ./bosh-init-*
sudo mv ./bosh-init-* /usr/local/bin/bosh-init

echo "Finish"
