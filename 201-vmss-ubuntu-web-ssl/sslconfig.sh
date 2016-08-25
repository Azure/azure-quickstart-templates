#!/bin/bash

set -e

servers=("10.0.2.10" "10.0.2.11" "10.0.100.4" "10.0.100.5" "10.0.100.7" )
certFileName="ssl.cer"
keyFileName="ssl.key"
caFileName="ca.cert"

for i in "${servers[@]}"
do
    echo $i
    
    sed -i '/SSLCertificateFile/d' /etc/apache2/sites-enabled/default-ssl-2.conf
    sed -i '/SSLCertificateKeyFile/d' /etc/apache2/sites-enabled/default-ssl-2.conf
    sed -i '/SSLCertificateChainFile/d' /etc/apache2/sites-enabled/default-ssl-2.conf
    
    printf "SSLCertificateFile %s\n" $certFileName
    echo 'SSLCertificateKeyFile $keyFileName' 
    echo 'SSLCertificateChainFile $caFileName' 
    
done

