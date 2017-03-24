#!/bin.bash
FQDN=$1
echo "api_fqdn '$FQDN'" | sudo tee -a /etc/chef-marketplace/marketplace.rb 
sudo sed -i "s/^fqdn .*/fqdn '$FQDN'/" /etc/chef-compliance/chef-compliance.rb 
sudo chef-marketplace-ctl hostname $FQDN 
sudo chef-compliance-ctl reconfigure