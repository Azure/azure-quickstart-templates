#!/bin/bash
echo "Starting Manifold installation"

mkdir /var/tmp/manifoldinstall
cd /var/tmp/manifoldinstall

curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u74-b02/jdk-8u74-linux-x64.rpm > jdk-8u74-linux-x64.rpm
yum install -y jdk-8u74-linux-x64.rpm

curl -X GET https://s3-us-west-2.amazonaws.com/rpmhost/rest-server-0.1-1.x86_64.rpm > rest-server-0.1-1.x86_64.rpm
yum install -y rest-server-0.1-1.x86_64.rpm

curl -X GET https://s3-us-west-2.amazonaws.com/rpmhost/manifold.crt > manifold.crt
sudo keytool -import -alias manifold -noprompt -trustcacerts -file manifold.crt -keystore /usr/java/latest/jre/lib/security/cacerts -storepass changeit

systemctl start rest-server
cd /home/
rm -rf /var/tmp/manifoldinstall

echo "Manifold installation Complete"
