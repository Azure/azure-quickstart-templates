#! /bin/sh
puname="puppet"
sed -i "2i$1 $2" /etc/hosts
sed -i "2i$1 $puname" /etc/hosts
rpm -ivh http://pm.puppetlabs.com/puppet-agent/2016.1.2/1.4.2/repos/el/7/PC1/x86_64/puppet-agent-1.4.2-1.el7.x86_64.rpm
yum install puppet -y
systemctl start puppet
