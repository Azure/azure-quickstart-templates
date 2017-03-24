sudo wget https://s3-us-west-2.amazonaws.com/bjcpublic/chef-gate-latest.deb -O /tmp/chef-gate-latest.deb
sudo wget  https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_12.8.0-1_amd64.deb -O /tmp/chef-server-core_12.8.0-1_amd64.deb
sudo sed -i -e 's/aio/server/g' /etc/chef-marketplace/marketplace.rb
sudo sed -i -e 's/chef-marketplace/standalone/g' /etc/opscode/chef-server.rb
sudo chef-server-ctl upgrade
sudo chef-server-ctl start
sudo chef-server-ctl cleanup
echo data_collector[\'root_url\'] = \'https://10.7.3.7/data-collector/v0/\' |  sudo tee --append  /etc/opscode/chef-server.rb
echo data_collector[\'token\'] = \'93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506\' |  sudo tee --append  /etc/opscode/chef-server.rb
sudo opscode-analytics-ctl stop
sudo rm /var/opt/opscode/nginx/etc/nginx.d/analytics.conf
sudo chef-server-ctl restart
