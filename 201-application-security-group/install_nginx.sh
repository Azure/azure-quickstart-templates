sudo yum install epel-release -y
sudo yum install nginx -y
sudo sed -i "/        <title>Test Page for the Nginx HTTP Server on EPEL<\/title>/c\<title>Test Page for the Nginx HTTP Server on EPEL - ${HOSTNAME}<\/title>" /usr/share/nginx/html/index.html
sudo sed -i "/        <h1>Welcome to <strong>nginx<\/strong> on EPEL\!<\/h1>/c\        <h1>Welcome to <strong>nginx<\/strong> on EPEL\! ${HOSTNAME}<\/h1>" /usr/share/nginx/html/index.html
sudo chkconfig nginx on
sudo /etc/init.d/nginx start
