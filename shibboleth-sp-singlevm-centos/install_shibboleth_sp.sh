domain=$1
location=$2

echo "Domain - $1 location - $2">>inputval.txt

SITENAME=$1.$2.cloudapp.azure.com
IpAddress=$(dig +short $SITENAME)

#Download shibboleth repository
cd /etc/yum.repos.d/

curl -o /etc/yum.repos.d/security:shibboleth.repo http://download.opensuse.org/repositories/security://shibboleth/CentOS_7/security:shibboleth.repo

yum --enablerepo=security_shibboleth install shibboleth -y

#Shibboleth installation pre-requisite 

yum install ntp -y
yum install httpd php mod_ssl -y

systemctl start ntpd
systemctl start shibd
systemctl start  httpd

#Set SElinux  mode to permissive
setenforce 0

#curl -k https://127.0.0.1/Shibboleth.sso/Status

cd /etc/shibboleth
 
cp  shibboleth2.xml shibboleth2.org  

#Apache  Hardening Script

sed -i "s|#ServerName.*|ServerName https://$SITENAME\nUseCanonicalName On\n|"  /etc/httpd/conf/httpd.conf

#Shibboleth Hardening Script
sed -i "s/::1/::1 $IpAddress /" /etc/shibboleth/shibboleth2.xml

sed -i "s/sp\.example\.org/$SITENAME/" /etc/shibboleth/shibboleth2.xml
sed  -i "7i <RequestMapper type=\"Native\">\n<RequestMap applicationId=\"default\"> \n <Host name=\"$SITENAME\">\n  	<Path name=\"secure\" authType=\"shibboleth\" requireSession=\"true\"\/>\n <\/Host>\n <\/RequestMap>\n<\/RequestMapper>" /etc/shibboleth/shibboleth2.xml
sed -i "s/handlerSSL=\"false\"/handlerSSL=\"true\"/" /etc/shibboleth/shibboleth2.xml
sed -i "s/cookieProps=\"http\"/cookieProps=\"https\"/" /etc/shibboleth/shibboleth2.xml
sed -i  "s/discoveryProtocol=\"SAMLDS.*//" /etc/shibboleth/shibboleth2.xml
#sed -i  "s/<SSO entityID.*/ <SSO entityID=\"urn:mace:incommon:washington.edu\">/" /etc/shibboleth/shibboleth2.xml

#Restart Shibboleth and apache server
systemctl restart shibd
systemctl restart httpd

#Create secured direcory 
mkdir /var/www/html/secure

echo "<?php 
header('Location:https://'.\$_SERVER['SERVER_NAME'].'/Shibboleth.sso/Session');
?>" >> /var/www/html/secure/index.php

