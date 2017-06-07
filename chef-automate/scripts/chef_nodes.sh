echo data_collector.server_url '"https://10.7.3.7/data-collector/v0/"' |  sudo tee --append  /etc/chef/client.rb
echo data_collector.token '"93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506"'  |  sudo tee --append  /etc/chef/client.rb
sudo chef-client
