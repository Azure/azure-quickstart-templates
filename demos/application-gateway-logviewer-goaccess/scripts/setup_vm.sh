#!/bin/bash

#The MIT License (MIT)
#Copyright (c) Microsoft Corporation. All rights reserved.
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the Software), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Add Microsoft Repo
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

# Add Official GoAccess Repository
echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/goaccess.list
wget -O - https://deb.goaccess.io/gnugpg.key | sudo apt-key add -

apt-get -y install apt-transport-https

# Update Packages
apt-get -y update

#Install Libcurl3, unzip
apt-get -y install libcurl3 unzip

#Install .Net Core current version
apt-get -y install aspnetcore-runtime-2.1

# Install Log Processor Application
systemctl stop appgatewaylogprocessor
systemctl stop goaccess
mkdir -p /var/log/azure/Microsoft.Azure.Networking.ApplicationGateway.LogProcessor
touch /var/log/azure/Microsoft.Azure.Networking.ApplicationGateway.LogProcessor/access.log
mkdir -p /usr/share/appgatewaylogprocessor
unzip -o AppGatewayLogProcessor.zip -d /usr/share/appgatewaylogprocessor/
sh /usr/share/appgatewaylogprocessor/files/scripts/setup_application.sh

# Setup the Template Params
echo $1 >> /usr/share/appgatewaylogprocessor/blobsasuri.key
chmod 644 /usr/share/appgatewaylogprocessor/blobsasuri.key
echo $2 >> /usr/share/appgatewaylogprocessor/appgwlogsbloburlregex
chmod 644 /usr/share/appgatewaylogprocessor/appgwlogsbloburlregex

# Install the Application Gateway Log Processor & GoAccess Service
cp /usr/share/appgatewaylogprocessor/files/appgatewaylogprocessor.service /etc/systemd/system/appgatewaylogprocessor.service
cp /usr/share/appgatewaylogprocessor/files/goaccess.service /etc/systemd/system/goaccess.service
systemctl daemon-reload
sudo systemctl enable appgatewaylogprocessor.service
sudo systemctl enable goaccess.service

# Start the Application Gateway Log Processor
systemctl start appgatewaylogprocessor

# Install Apache2 and GoAccess
apt-get -y install libncursesw5-dev gcc make libgeoip-dev libtokyocabinet-dev build-essential
apt-get -y install apache2
wget -q -O goaccess-1.2.tar.gz https://tar.goaccess.io/goaccess-1.2.tar.gz
tar -xzvf goaccess-1.2.tar.gz
cd goaccess-1.2/
./configure --enable-utf8 --enable-geoip=legacy
make
make install

# restart Apache
apachectl restart

# Start GoAccess
systemctl start goaccess
