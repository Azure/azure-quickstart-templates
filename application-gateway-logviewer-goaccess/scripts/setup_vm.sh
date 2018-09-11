#!/bin/bash

#The MIT License (MIT)
#Copyright (c) Microsoft Corporation. All rights reserved.
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the Software), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Update Packages 
apt-get -y update

#Install Libcurl3, unzip
apt-get -y install libcurl3 unzip

# Install .Net Core current version
# sh dotnet-install.sh -c Current
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

apt-get -y install apt-transport-https
apt-get -y update
apt-get -y install aspnetcore-runtime-2.1

# Install Log Processor Application
mkdir /var/log/azure/Microsoft.Azure.Networking.ApplicationGateway.LogProcessor
touch /var/log/azure/Microsoft.Azure.Networking.ApplicationGateway.LogProcessor/access_log.log
unzip -o publish.zip
mv publish /usr/share/appgatewaylogprocessor

# Setup the Template Params
echo $1 >> /usr/share/appgatewaylogprocessor/blobsasuri.key
chmod 644 /usr/share/appgatewaylogprocessor/blobsasuri.key
echo $2 >> /usr/share/appgatewaylogprocessor/appgwlogsbloburlregex
chmod 644 /usr/share/appgatewaylogprocessor/appgwlogsbloburlregex

# Start the Application Gateway Log Processor
dotnet /usr/share/appgatewaylogprocessor/AppGatewayLogProcessor.dll &

# Install and Setup GoAccess
sh install_goaccess.sh
