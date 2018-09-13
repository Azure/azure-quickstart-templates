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
wget -q -O AppGatewayLogProcessor.zip "https://appgwloganalyzergoaccess.blob.core.windows.net/loganalyzerservice/build/AppGatewayLogProcessor.zip?st=2018-09-12T06%3A56%3A42Z&se=2050-09-13T06%3A56%3A00Z&sp=rl&sv=2018-03-28&sr=b&sig=c9x6svGOKJOHvHEwCDzM9BSrO5FwPRMIDhuQ4m1OeWQ%3D"
systemctl stop appgatewaylogprocessor
mkdir -p /var/log/azure/Microsoft.Azure.Networking.ApplicationGateway.LogProcessor
touch /var/log/azure/Microsoft.Azure.Networking.ApplicationGateway.LogProcessor/access_log.log
mkdir -p /usr/share/appgatewaylogprocessor
unzip -o AppGatewayLogProcessor.zip -d /usr/share/appgatewaylogprocessor/
sh /usr/share/appgatewaylogprocessor/files/scripts/setup_application.sh

# Setup the Template Params
echo $1 >> /usr/share/appgatewaylogprocessor/blobsasuri.key
chmod 644 /usr/share/appgatewaylogprocessor/blobsasuri.key
echo $2 >> /usr/share/appgatewaylogprocessor/appgwlogsbloburlregex
chmod 644 /usr/share/appgatewaylogprocessor/appgwlogsbloburlregex

# Install the Application Gateway Log Processor Service
cp /usr/share/appgatewaylogprocessor/files/appgatewaylogprocessor.service /etc/systemd/system/appgatewaylogprocessor.service
systemctl daemon-reload;sudo systemctl enable appgatewaylogprocessor.service

# Start the Application Gateway Log Processor
#dotnet /usr/share/appgatewaylogprocessor/AppGatewayLogProcessor.dll &
systemctl start appgatewaylogprocessor

# Install Apache2 and GoAccess
apt-get -y install apache2 goaccess

# restart Apache
apachectl restart

# Start GoAccess
goaccess /var/log/azure/Microsoft.Azure.Networking.ApplicationGateway.LogProcessor/access_log.log -o /var/www/html/report.html --real-time-html --port=8080 --log-format='"%^": "%dT%t+%^","%^": {%^=>%^, %^=>"%h", %^=>%^, %^=>"%m", %^=>"%U", %^=>"%q", %^=>"%u", %^=>"%s", %^=>"%H", %^=>"%b", %^=>%^, %^=>"%T", %^=>%^},' --time-format='%T' --date-format='%Y-%m-%d' &
