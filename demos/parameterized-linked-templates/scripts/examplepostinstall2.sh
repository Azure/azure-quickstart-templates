#!/bin/bash
echo ExamplePostInstall2.sh was run at $(date)
if hash zypper; then
  zypper install -y python3-pip screen
else
  yum install -y python3-pip screen
  firewall-cmd --zone=public --add-port=80/tcp --permanent
  firewall-cmd --reload
fi
python3 -m pip install http.server
echo "<html><body>Test HTTP Server Running on $(curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/name?api-version=2017-08-01&format=text")</body></html>" > index.html
/usr/bin/screen -dmS simple-web python3 -m http.server 80
