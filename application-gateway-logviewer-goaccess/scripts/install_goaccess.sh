#!/bin/bash

#The MIT License (MIT)
#Copyright (c) Microsoft Corporation. All rights reserved.
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the Software), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Add Official GoAccess Repository
echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/goaccess.list
wget -O - https://deb.goaccess.io/gnugpg.key | sudo apt-key add -

# Update Packages 
apt-get -y update

# Install Apache2
apt-get -y install apache2

# Install GoAccess
apt-get -y install goaccess

# restart Apache
apachectl restart

# Start GoAccess
goaccess /var/log/azure/Microsoft.Azure.Networking.ApplicationGateway.LogProcessor/access_log.log -o /var/www/html/report.html --real-time-html --port=8080 --log-format='"%^": "%dT%t+%^","%^": {%^=>%^, %^=>"%h", %^=>%^, %^=>"%m", %^=>"%U", %^=>"%q", %^=>"%u", %^=>"%s", %^=>"%H", %^=>"%b", %^=>%^, %^=>"%T", %^=>%^},' --time-format='%T' --date-format='%Y-%m-%d' &
