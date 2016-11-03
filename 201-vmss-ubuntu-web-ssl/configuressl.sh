#!/bin/bash

# exit on any error
set -e

echo "Welcome to configuressl.sh"
echo "Number of parameters was: " $#

if [ $# -lt 1 ]; then
    echo usage: $0 [certificatefingerprint] [CAcertificatefingerprint]      
	exit 1
fi

echo "Checking for apache2 already installed"
if dpkg -s apache2 > /dev/null 2>&1; then
     echo "Apache2 installed already - exiting"
     exit
else
     echo "Apache2 not installed - proceeding"
fi

# install needed bits in a loop because a lot of installs happen
# on VM init, so won't be able to grab the dpkg lock immediately
until apt-get -y update && apt-get -y install apache2 
do
  echo "Trying again"
  sleep 2
done

# turn off apache until we are done with setup
# Azure LB HTTP/s Probe will fail and not direct traffic to VM 
apachectl stop

# Enable ssl in apache
a2enmod ssl
a2ensite default-ssl

certprint=$1


sslcertfilename=$certprint'.crt'
sslkeyfilename=$certprint'.prv'


echo "Copying SSL files"
echo "cert file" $sslcertfilename
fullpath=/var/lib/waagent/$sslcertfilename
if [ -f $fullpath ]
then
    cp $fullpath /etc/ssl/certs/
else
    echo "Cert missing: " $fullpath
    exit 1
fi

echo "private key file" $sslkeyfilename
fullpath=/var/lib/waagent/$sslkeyfilename
if [ -f $fullpath ]
then
    cp $fullpath /etc/ssl/private/
else
    echo "Private Key missing: " $fullpath
    exit 1
fi

echo "configuring certfile"
sed -i 's/#*SSLCertificateFile.*$/SSLCertificateFile \/etc\/ssl\/certs\/'$sslcertfilename'/g' /etc/apache2/sites-enabled/default-ssl.conf
echo "keyfile"
sed -i 's/#*SSLCertificateKeyFile.*$/SSLCertificateKeyFile \/etc\/ssl\/private\/'$sslkeyfilename'/g' /etc/apache2/sites-enabled/default-ssl.conf

if [ ! -z "$2" ] 
    then
        echo "CA cert thumbprint present. Configuring ..."
        cacertprint=$2
        sslcafilename=$cacertprint'.crt'
        echo "CA cert file" $sslcafilename
        fullpath=/var/lib/waagent/$sslcafilename
        if [ -f $fullpath ]
        then
            cp $fullpath /etc/ssl/certs/
        else
            echo "Cert missing: " $fullpath
            exit 1
        fi

        echo "Configuring Apache for CA cert"
        sed -i 's/#*SSLCertificateChainFile.*$/SSLCertificateChainFile \/etc\/ssl\/certs\/'$sslcafilename'/g' /etc/apache2/sites-enabled/default-ssl.conf
    else
        echo "No CA thumbprint. Assuming self-signed"
fi

echo "restarting apache"
# all done - turn apache on
apachectl start

echo "Done!"
