#!/bin/bash
#
# Nginx - new server blocks
#
# Variables
NGINX_AVAILABLE_VHOSTS='/etc/nginx/sites-available'
NGINX_ENABLED_VHOSTS='/etc/nginx/sites-enabled'
WEB_DIR='/var/www'
WEB_USER='www-data'
NGINX_LOG='/var/log/nginx'
#
#WEB_ARRAY_NAME=("web101" "web102" "web103" "web104")
#WEB_ARRAY_PORT=("8081" "8082" "8083" "8084")


WEB_ARRAY_NAME=()
WEB_ARRAY_PORT=("$@")
#for arg in "${WEB_ARRAY_PORT[@]}"; do
#	echo "$arg"
#done
#echo "${WEB_ARRAY_PORT[*]}"
argc=$#
for (( j=0; j<$argc; j++ )); do
    k=$(($j+1))
    printf -v i "%02d" $k
    WEB_ARRAY_NAME+=("web${i}")
done
#echo "${WEB_ARRAY_NAME[*]}"

sleep 1m

if [ "${UID}" -ne 0 ];
then
    echo "Script executed without root permissions"
    echo "You must be root to run this script." >&2
    exit 3
fi

# eliminate debconf warnings
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

sudo apt-get -y update
# sudo apt upgrade
### install and start nginx
sudo apt-get -y install nginx 
sudo systemctl enable nginx 
sudo systemctl start nginx
### change the homepage of nginx
echo '<style> h1 { color: blue; } </style> <h1>' > /var/www/html/index.nginx-debian.html
cat /etc/hostname >> /var/www/html/index.nginx-debian.html
echo ' </h1>' >> /var/www/html/index.nginx-debian.html
sed -i '/^#/! s/listen 80/listen 8080/g'  /etc/nginx/sites-enabled/default
sed -i '/^#/! s/listen \[::]:80/listen \[::]:8080/g' /etc/nginx/sites-enabled/default
systemctl restart nginx



for i in ${!WEB_ARRAY_NAME[@]}; do
    ### Create folders 
    if [ -d "$WEB_DIR/${WEB_ARRAY_NAME[$i]}/html" ]; then
      echo "folder $WEB_DIR/${WEB_ARRAY_NAME[$i]}/html already exists"
    else
      mkdir -p $WEB_DIR/${WEB_ARRAY_NAME[$i]}/html
    fi
done


for i in ${!WEB_ARRAY_NAME[@]}; do
   ### Assign ownership
   chown -R $USER:$USER $WEB_DIR/${WEB_ARRAY_NAME[$i]}/html
done

### Grant reading permission to all the files inside the /var/www directory
sudo chmod -R 755 $WEB_DIR

for i in ${!WEB_ARRAY_NAME[@]}; do
   ### Reassign ownership of the web directories to NGINX user (www-data):
   chown -R www-data:www-data $WEB_DIR/${WEB_ARRAY_NAME[$i]}/html
done

COLORS=("darkgreen" "darkblue" "red" "darkviolet" "orangered")
LEN=${#COLORS[@]}

for i in ${!WEB_ARRAY_NAME[@]}; do
### Create the content you want to display on the websites hosted on Nginx server 
cat <<EOF > $WEB_DIR/${WEB_ARRAY_NAME[$i]}/html/index.html
<html>
    <style> h1 { color: ${COLORS[$((i%LEN))]}; } </style> <h1>
    <head> <title>Welcome to ${WEB_ARRAY_NAME[$i]}</title> </head>
    <body>
        <h1>${WEB_ARRAY_NAME[$i]} server block is working!</h1>
    </body>
</html>
EOF
done


### Inside the  file /etc/nginx/nginx.conf check the two lines:
###    include /etc/nginx/conf.d/*.conf;
###    include /etc/nginx/sites-enabled/*;
### The line include /etc/nginx/sites-enabled/*.conf instructs NGINX to check the sites-enabled directory.

for i in ${!WEB_ARRAY_NAME[@]}; do
### Create the server blocks for the site web101
cat <<EOF > /etc/nginx/sites-available/${WEB_ARRAY_NAME[$i]}.conf
server {
        listen ${WEB_ARRAY_PORT[$i]};
        listen [::]:${WEB_ARRAY_PORT[$i]};
        server_name  ${WEB_ARRAY_NAME[$i]}.local;

        root $WEB_DIR/${WEB_ARRAY_NAME[$i]}/html;
        index index.html index.htm;
        location / {
                try_files \$uri \$uri/ =404;
        }
        access_log /var/log/nginx/${WEB_ARRAY_NAME[$i]}/access.log;
	    error_log /var/log/nginx/${WEB_ARRAY_NAME[$i]}/error.log;
}
EOF
done

### Enable the new server block files, by creating symbolic links:
for i in ${!WEB_ARRAY_NAME[@]}; do
   ### Enable the new server block files, by creating symbolic links:
   #ln -s /etc/nginx/sites-available/${WEB_ARRAY_NAME[$i]}.conf /etc/nginx/sites-enabled/
   
   web_link="/etc/nginx/sites-enabled/${WEB_ARRAY_NAME[$i]}.conf"
   if [ -L ${web_link} ] ; then
     if [ -e ${web_link} ] ; then
        echo "symbolic link already exists: /etc/nginx/sites-enabled/${WEB_ARRAY_NAME[$i]}.conf"
     else
        echo "symbolic link  /etc/nginx/sites-enabled/${WEB_ARRAY_NAME[$i]}.conf is broken"
     fi
   elif [ -e ${web_link} ] ; then
     echo " /etc/nginx/sites-enabled/${WEB_ARRAY_NAME[$i]}.conf is NOT a symbolic link "
   else
     echo "Create symbolic link: /etc/nginx/sites-enabled/${WEB_ARRAY_NAME[$i]}.conf"
     ln -s /etc/nginx/sites-available/${WEB_ARRAY_NAME[$i]}.conf /etc/nginx/sites-enabled/
   fi
done

for i in ${!WEB_ARRAY_NAME[@]}; do
   ### Create the folders for the logs:
   mkdir -p /var/log/nginx/${WEB_ARRAY_NAME[$i]}/
   chown -R www-data:adm /var/log/nginx/${WEB_ARRAY_NAME[$i]}/
done
### Check errors in nginx configuration
sudo nginx -t

### Restart NGINX:
sudo systemctl restart nginx
