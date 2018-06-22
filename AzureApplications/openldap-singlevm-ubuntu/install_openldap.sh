#!/bin/bash

# parameters
adminpass=$1
subdomain=$2
location=$3
organization=$4

# variables
domain=$subdomain.$location.cloudapp.azure.com
base="dc=$subdomain,dc=$location,dc=cloudapp,dc=azure,dc=com"

# install debconf
apt-get -y update
apt-get install debconf

# silent install of slapd
export DEBIAN_FRONTEND=noninteractive
echo slapd slapd/password1 password $adminpass | debconf-set-selections
echo slapd slapd/password2 password $adminpass | debconf-set-selections
echo slapd slapd/allow_ldap_v2 boolean false | debconf-set-selections
echo slapd slapd/domain string $domain | debconf-set-selections
echo slapd slapd/no_configuration boolean false | debconf-set-selections
echo slapd slapd/move_old_database boolean true | debconf-set-selections
# echo slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION | debconf-set-selections
echo slapd slapd/purge_database boolean false | debconf-set-selections
echo slapd shared/organization string $organization | debconf-set-selections
echo slapd slapd/backend select HDB | debconf-set-selections

apt-get -y install slapd ldap-utils

# Install for TLS support
apt-get -y install gnutls-bin ssl-cert

# Create dir for certificates
mkdir /etc/ssl/slapd

# Generate a private key for the certificate
certtool --generate-privkey > /etc/ssl/slapd/cakey.pem

# Create ca.info
echo "cn = $domain" > /etc/ssl/slapd/ca.info
echo "ca" >> /etc/ssl/slapd/ca.info
echo "cert_signing_key" >> /etc/ssl/slapd/ca.info

# Create CA certificate
certtool --generate-self-signed --load-privkey /etc/ssl/slapd/cakey.pem --template /etc/ssl/slapd/ca.info --outfile /etc/ssl/slapd/cacert.pem

# Generate private key for the server
certtool --generate-privkey --bits 2048 --outfile /etc/ssl/slapd/ldaps_slapd_key.pem

# Create template for server certificate
echo "organization = $organization" > /etc/ssl/slapd/ldaps.info
echo "cn = $domain" >> /etc/ssl/slapd/ldaps.info
echo "tls_www_server" >> /etc/ssl/slapd/ldaps.info
echo "encryption_key" >> /etc/ssl/slapd/ldaps.info
echo "signing_key" >> /etc/ssl/slapd/ldaps.info
echo "expiration_days = 3650" >> /etc/ssl/slapd/ldaps.info

# Create the certificate
certtool --generate-certificate \
--load-privkey /etc/ssl/slapd/ldaps_slapd_key.pem \
--load-ca-certificate /etc/ssl/slapd/cacert.pem \
--load-ca-privkey /etc/ssl/slapd/cakey.pem \
--template /etc/ssl/slapd/ldaps.info \
--outfile /etc/ssl/slapd/ldaps_slapd_cert.pem

# Add TLS settings to the config
ldapmodify -Y EXTERNAL -H ldapi:/// -f ./setTLSConfig.ldif

# Secure the keys
adduser openldap ssl-cert
chgrp ssl-cert /etc/ssl/slapd/ldaps_slapd_key.pem
chmod g+r /etc/ssl/slapd/ldaps_slapd_key.pem
chmod o-r /etc/ssl/slapd/ldaps_slapd_key.pem

# Give apparmor access to cert files
# TODO: This regex could be made more robust
sed -i "/\/usr\/sbin\/slapd mr,/ s/$/\n\n  \/etc\/ssl\/slapd\/ r,\n  \/etc\/ssl\/slapd\/* r,/" /etc/apparmor.d/usr.sbin.slapd
service apparmor reload
/etc/init.d/slapd restart

# force TLS
ldapmodify -Y EXTERNAL -H ldapi:/// -f ./forceTLS.ldif

# Backup existing ldap.config and create new one
cp /etc/ldap/ldap.conf /etc/ldap/ldap.conf.old
echo "BASE $base" > /etc/ldap/ldap.conf
echo "ldap:// ldaps:// ldapi://" >> /etc/ldap/ldap.conf
echo "TLS_CACERT /etc/ssl/slapd/cacert.pem" >> /etc/ldap/ldap.conf
echo "TLS_REQCERT demand" >> /etc/ldap/ldap.conf

# Install phpldapadmin
sudo apt-get -y install phpldapadmin

# Backup existing config.php file for phpldapadmin and create a new one
cp /etc/phpldapadmin/config.php /etc/phpldapadmin/config.php.old
echo "<?php " > /etc/phpldapadmin/config.php
echo "\$servers = new Datastore();" >> /etc/phpldapadmin/config.php
echo "\$servers->newServer('ldap_pla');" >> /etc/phpldapadmin/config.php
echo "\$servers->setValue('server','name','$organization');" >> /etc/phpldapadmin/config.php
echo "\$servers->setValue('server','host','$domain');" >> /etc/phpldapadmin/config.php
echo "\$servers->setValue('server','base',array('$base'));" >> /etc/phpldapadmin/config.php
echo "\$servers->setValue('login','bind_id','cn=admin,$base');" >> /etc/phpldapadmin/config.php
echo "\$servers->setValue('server','tls',true);" >> /etc/phpldapadmin/config.php
echo "\$config->custom->appearance['hide_template_warning'] = true;" >> /etc/phpldapadmin/config.php
echo "?>" >> /etc/phpldapadmin/config.php

# Backup existing /usr/share/phpldapadmin/lib/TemplateRender.php and change password_hash to password_hash_custom (to take care of template error)
cp /usr/share/phpldapadmin/lib/TemplateRender.php /usr/share/phpldapadmin/lib/TemplateRender.php.old
sed -i "s/password_hash/password_hash_custom/" /usr/share/phpldapadmin/lib/TemplateRender.php

# Enable SSL on Apache
a2enmod ssl

# edit default-ssl.conf
sed -i '/^[[:space:]]*SSLCertificateFile[[:space:]]/ s/^.*/SSLCertificateFile \/etc\/ssl\/slapd\/ldaps_slapd_cert.pem/' /etc/apache2/sites-available/default-ssl.conf
sed -i '/^[[:space:]]*SSLCertificateKeyFile[[:space:]]/ s/^.*/SSLCertificateKeyFile \/etc\/ssl\/slapd\/ldaps_slapd_key.pem/' /etc/apache2/sites-available/default-ssl.conf

a2ensite default-ssl

# restart Apache
apachectl restart
