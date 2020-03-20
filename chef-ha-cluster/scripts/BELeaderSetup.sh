# Primary BE setup
apt-get install -y apt-transport-https
wget -qO - https://downloads.chef.io/packages-chef-io-public.key | sudo apt-key add -
echo "deb https://packages.chef.io/stable-apt trusty main" > /etc/apt/sources.list.d/chef-stable.list
apt-get update

# store data on persisten, external volume
apt-get install lvm2 xfsprogs sysstat atop -y
umount -f /mnt
pvcreate -f /dev/SOMETHING
vgcreate chef-vg /dev/SOMETHING
lvcreate -n chef-lv -l 80%VG chef-vg
mkfs.xfs /dev/chef-vg/chef-lv
mkdir -p /var/opt/chef-backend
mount /dev/chef-vg/chef-lv /var/opt/chef-backend

# Chef server setup
apt-get install -y chef-backend

# Grab IP address and prepopulate configuration
IPADRESS=`ifconfig eth0 | awk '/inet addr/{print substr($2,6)}'`
cat > /etc/chef-backend/chef-backend.rb <<EOF
publish_address '${IPADRESS}'
postgresql.log_min_duration_statement = 500
elasticsearch.heap_size = 3500
EOF

chef-backend-ctl create-cluster --accept-license --yes --quiet --verbose

curl --retry 3 --silent --show-error --upload-file /etc/chef-backend/chef-backend-secrets.json "$1/chef-backend-secrets.json$2" --header "x-ms-blob-type: BlockBlob"
chef-backend-ctl gen-server-config fe0 -f chef-server.rb.fe0
curl --retry 3 --silent --show-error --upload-file chef-server.rb.fe0 "$1/chef-server.rb.fe0$2" --header "x-ms-blob-type: BlockBlob"
chef-backend-ctl gen-server-config fe1 -f chef-server.rb.fe1
curl --retry 3 --silent --show-error --upload-file chef-server.rb.fe1 "$1/chef-server.rb.fe1$2" --header "x-ms-blob-type: BlockBlob"
chef-backend-ctl gen-server-config fe2 -f chef-server.rb.fe2
curl --retry 3 --silent --show-error --upload-file chef-server.rb.fe2 "$1/chef-server.rb.fe2$2" --header "x-ms-blob-type: BlockBlob"

# enable basic data collection
echo 'ENABLED="true"' > /etc/default/sysstat
service sysstat start
