#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2015 Microsoft Azure
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

apt-get update -y && apt-get upgrade -y
apt-get install -y nginx
echo "Hello World from host" $HOSTNAME "!" | sudo tee -a /var/www/html/index.html

touch /etc/nginx/nginx.conf
cat >> /etc/nginx/nginx.conf <<EOF
stream {
      upstream dns_servers {
       server 168.63.129.16:53;
}

server {
 listen x.x.x.x:53  udp;
 listen x.x.x.x:53; #tcp
 proxy_pass dns_servers;
 proxy_responses 1;
 error_log  /var/log/nginx/dns.log info;
}
}
EOF

myip=`hostname -i | awk '{print $1}'`
sed -i "s/x.x.x.x/$myip/" /etc/nginx/nginx.conf


sudo nginx -t && sudo service nginx reload