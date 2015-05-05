#!/bin/sh
sudo apt-get update
sudo apt-get install -y git libsqlite3-dev libxml2-dev libxslt-dev libmysqlclient-dev libpq-dev ruby1.9.3 ruby-dev gcc make g++ postgresql  redis-server mercurial bundler cmake pkg-config nodejs-legacy npm

sudo npm install azure-cli optimist azure-mgmt-resource retry async azure-common  -g

pushd .
mkdir src
cd src
git clone https://github.com/qingfuwang/bosh.git -b azure_cpi_crp
cd bosh
bundle install --local

cd bosh_common
gem build bosh_common.gemspec
sudo gem install bosh_common-1.2807.0.gem --no-ri --no-rdoc

cd ../blobstore_client
gem build blobstore_client.gemspec
sudo gem install blobstore_client-1.2807.0.gem --no-ri --no-rdoc

cd ../bosh-template
gem build bosh-template.gemspec
sudo gem install bosh-template-1.2807.0.gem --no-ri --no-rdoc

cd ../bosh-registry
gem build bosh-registry.gemspec
sudo gem install bosh-registry-1.2807.0.gem --no-ri --no-rdoc

cd ../bosh_cpi
gem build bosh_cpi.gemspec
sudo gem install bosh_cpi-1.2807.0.gem --no-ri --no-rdoc

cd ../bosh_aws_cpi
gem build bosh_aws_cpi.gemspec
sudo gem install bosh_aws_cpi-1.2807.0.gem --no-ri --no-rdoc

cd ../bosh_openstack_cpi
gem build bosh_openstack_cpi.gemspec
sudo gem install bosh_openstack_cpi-1.2807.0.gem --no-ri --no-rdoc

cd ../bosh_vsphere_cpi
gem build bosh_vsphere_cpi.gemspec
sudo gem install bosh_vsphere_cpi-1.2807.0.gem --no-ri --no-rdoc

cd ../bosh-stemcell
gem build bosh-stemcell.gemspec
sudo gem install bosh-stemcell-1.2807.0.gem --no-ri --no-rdoc

cd ../agent_client
gem build agent_client.gemspec
sudo gem install agent_client-1.2807.0.gem --no-ri --no-rdoc

cd ../bosh-director-core
gem build bosh-director-core.gemspec
sudo gem install bosh-director-core-1.2807.0.gem --no-ri --no-rdoc

cd ../bosh_cli
gem build bosh_cli.gemspec
sudo gem install bosh_cli-1.2807.0.gem --no-ri --no-rdoc

cd ../bosh_azure_cpi
gem build bosh_azure_cpi.gemspec
sudo gem install bosh_azure_cpi-1.2807.0.gem --no-ri --no-rdoc

cd ../bosh_cli_plugin_micro
gem build bosh_cli_plugin_micro.gemspec
sudo gem install bosh_cli_plugin_micro-1.2807.0.gem --no-ri --no-rdo