#!/bin/bash

# Set up Splunk node
# Usage:  $0 <splunk_role> <clustername> [<number-of-nodes> <this-node-index>]

set -e

echo "node-setup Started: $*. `date`"

[ $1 = '-v' ] && shift || quiet='-q'

myip="$(ip -4 address show eth0 | sed -rn 's/^[[:space:]]*inet ([[:digit:].]+)[/[:space:]].*$/\1/p')"

echo "IP: $myip"

# Strip data disks into one volume
chmod u+x vm-disk-utils-0.1.sh && ./vm-disk-utils-0.1.sh -s -p /opt/splunk

# Install chef client 12.5.1
wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/10.04/x86_64/chef_12.5.1-1_amd64.deb
# TODO: Check against sha1
dpkg -i chef_12.5.1-1_amd64.deb

# Setup chef repo & node attributes
mkdir -p /etc/chef/repo
cd /etc/chef/repo
curl -sL https://github.com/rarsan/chef-repo-splunk/tarball/v0.1 | tar -xz --strip-components=1
tar -xzf berks-package.tar.gz -C cookbooks --strip-components=1

cat >/etc/chef/node.json <<end
{
  "splunk": {
    "server": {
      "runasroot": "false"
    }
  },
  "run_list": [
    "role[splunk_server]"
  ]
}
end

cat >/etc/chef/client.rb <<end
log_level :info
log_location STDOUT
chef_repo_path "/etc/chef/repo"
end

# Run chef client in local mode
cd -
chef-client -z -j /etc/chef/node.json -c /etc/chef/client.rb

echo "node-setup Finished: $*. `date`"

exit 0