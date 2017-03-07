#!/bin/bash

#usage : ./init_aptly.sh -ar debianRepoName
# -ar : the aptly repo name

WORK_DIR="/var/lib/jenkins"
while [[ $# -gt 1 ]]
do
key="$1"

#in case we have more params to pass in later
case $key in
   -ar)
   APTLY_REPO_NAME="$2"
   echo "APTLY_REPO_NAME="$APTLY_REPO_NAME
   ;;
   *)

   ;;
esac
shift
done

echo "Downloading aptly to /var/lib/jenkins"
sudo sh -c "cd $WORK_DIR && pwd;wget https://dl.bintray.com/smira/aptly/0.9.5/debian-squeeze-x64/aptly;"
sudo chown jenkins:jenkins $WORK_DIR/aptly
sudo chmod +x $WORK_DIR/aptly

echo "Creating repo"
sudo -u jenkins -i << EOF
    $WORK_DIR/aptly repo create $APTLY_REPO_NAME
    $WORK_DIR/aptly publish repo -architectures="amd64" -component=main -distribution=trusty -skip-signing=true $APTLY_REPO_NAME
EOF

#install nginx
echo "Installing nginx"
sudo apt-get -y install nginx

#stop service
echo "Stopping nginx service"
sudo service nginx stop

NGINX_CONFIG_FILE=/etc/nginx/sites-enabled/default

#overwrite config to file
echo "Overwriting nginx config"
sudo sh -c "printf \"server {\n\" > $NGINX_CONFIG_FILE"
sudo sh -c "printf \"        listen 9999 default_server;\n\" >> $NGINX_CONFIG_FILE"
sudo sh -c "printf \"        listen [::]:9999 default_server ipv6only=on;\n\" >> $NGINX_CONFIG_FILE"
sudo sh -c "printf \"        root /var/lib/jenkins/.aptly/public;\n\" >> $NGINX_CONFIG_FILE"
sudo sh -c "printf \"        index index.html index.htm;\n\" >> $NGINX_CONFIG_FILE"
sudo sh -c "printf \"        server_name localhost;\n\" >> $NGINX_CONFIG_FILE"
sudo sh -c "printf \"        location / {\n\" >> $NGINX_CONFIG_FILE"
sudo sh -c "printf \"                try_files \044uri \044uri/ =404;\n\" >> $NGINX_CONFIG_FILE"
sudo sh -c "printf \"        }\n\" >> $NGINX_CONFIG_FILE"
sudo sh -c "printf \"}\n\" >> $NGINX_CONFIG_FILE"

echo "starting nginx service"
sudo service nginx start
