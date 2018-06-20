#!/bin/bash

# parameters
vmadminuser=$1
vmadminpass=$2
directoryadminpass=$3
subdomain=$4
location=$5
organization=$6
privateIPAddressPrefix=$7
vmCount=$8
index=$9

# variables
let "index+=1" # index is 0-based, but we want 1-based
domain=$subdomain.$location.cloudapp.azure.com
base="dc=$subdomain,dc=$location,dc=cloudapp,dc=azure,dc=com"
localdomain=ldap$index.$subdomain.local

# install debconf
apt-get -y update
apt-get install debconf

echo "===== Set up siltent install of slapd ====="
# silent install of slapd
export DEBIAN_FRONTEND=noninteractive
echo slapd slapd/password1 password $directoryadminpass | debconf-set-selections
echo slapd slapd/password2 password $directoryadminpass | debconf-set-selections
echo slapd slapd/allow_ldap_v2 boolean false | debconf-set-selections
echo slapd slapd/domain string $domain | debconf-set-selections
echo slapd slapd/no_configuration boolean false | debconf-set-selections
echo slapd slapd/move_old_database boolean true | debconf-set-selections
# echo slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION | debconf-set-selections
echo slapd slapd/purge_database boolean false | debconf-set-selections
echo slapd shared/organization string $organization | debconf-set-selections
echo slapd slapd/backend select HDB | debconf-set-selections

echo "===== Install slapd ====="
apt-get -y install slapd ldap-utils

echo "===== Set up TLS support ====="
apt-get -y install gnutls-bin ssl-cert sshpass

echo "===== Create entries in hosts file ====="
for i in `seq 1 $vmCount`; do
    let "j=i-1"
    echo "$privateIPAddressPrefix$j ldap$i.$subdomain.local ldap$i" >> /etc/hosts
done

echo "===== Modify slapd default configuration ====="
sed -i "s/SLAPD_SERVICES=\"ldap:\/\/\/ ldapi:\/\/\/\"/SLAPD_SERVICES=\"ldapi:\/\/\/ ldap:\/\/$localdomain\"/" /etc/default/slapd

echo "===== Create dir for certificates ====="
mkdir /etc/ssl/slapd

# Create CA certificate (only on the first server - the other servers will just copy it from here)
if [ "$index" = "1" ]; then
    echo "===== Generate a private key for the CA certificate ====="
    certtool --generate-privkey > /etc/ssl/slapd/cakey.pem

    echo "===== Create ca.info ====="
    echo "cn = $localdomain" > /etc/ssl/slapd/ca.info
    echo "ca" >> /etc/ssl/slapd/ca.info
    echo "cert_signing_key" >> /etc/ssl/slapd/ca.info

    echo "===== Create CA cert ====="
    certtool --generate-self-signed --load-privkey /etc/ssl/slapd/cakey.pem --template /etc/ssl/slapd/ca.info --outfile /etc/ssl/slapd/cacert.pem
else
    echo "===== Copy the CA certificate from the first server ====="
    sshpass -p "$vmadminpass" scp -o "StrictHostKeyChecking no" $vmadminuser@ldap1.$subdomain.local:/etc/ssl/slapd/cacert.pem /etc/ssl/slapd
    while [ ! -f /etc/ssl/slapd/cacert.pem ]; do
        sleep 2
        sshpass -p "$vmadminpass" scp -o "StrictHostKeyChecking no" $vmadminuser@ldap1.$subdomain.local:/etc/ssl/slapd/cacert.pem /etc/ssl/slapd
    done
    
    sshpass -p "$vmadminpass" scp -o "StrictHostKeyChecking no" $vmadminuser@ldap1.$subdomain.local:/etc/ssl/slapd/cakey.pem /etc/ssl/slapd
fi

echo "===== Generate private key for the server ====="
certtool --generate-privkey --bits 2048 --outfile /etc/ssl/slapd/ldaps_slapd_key.pem

echo "===== Create template for server certificate ====="
echo "organization = $organization" > /etc/ssl/slapd/ldaps.info
echo "cn = $domain" >> /etc/ssl/slapd/ldaps.info
echo "tls_www_server" >> /etc/ssl/slapd/ldaps.info
echo "encryption_key" >> /etc/ssl/slapd/ldaps.info
echo "signing_key" >> /etc/ssl/slapd/ldaps.info
echo "expiration_days = 3650" >> /etc/ssl/slapd/ldaps.info

echo "===== Create the certificate ====="
certtool --generate-certificate \
--load-privkey /etc/ssl/slapd/ldaps_slapd_key.pem \
--load-ca-certificate /etc/ssl/slapd/cacert.pem \
--load-ca-privkey /etc/ssl/slapd/cakey.pem \
--template /etc/ssl/slapd/ldaps.info \
--outfile /etc/ssl/slapd/ldaps_slapd_cert.pem

echo "===== Add TLS settings to the config ====="
ldapmodify -Y EXTERNAL -H ldapi:/// -f ./setTLSConfig.ldif

echo "===== Secure the keys ====="
adduser openldap ssl-cert
chgrp ssl-cert /etc/ssl/slapd/ldaps_slapd_key.pem
chmod g+r /etc/ssl/slapd/ldaps_slapd_key.pem
chmod o-r /etc/ssl/slapd/ldaps_slapd_key.pem

echo "===== Give apparmor access to cert files ====="
# TODO: This regex could be made more robust
sed -i "/\/usr\/sbin\/slapd mr,/ s/$/\n\n  \/etc\/ssl\/slapd\/ r,\n  \/etc\/ssl\/slapd\/* r,/" /etc/apparmor.d/usr.sbin.slapd
service apparmor reload
/etc/init.d/slapd restart

echo "===== Backup existing ldap.config and create new one ====="
cp /etc/ldap/ldap.conf /etc/ldap/ldap.conf.old
echo "BASE $base" > /etc/ldap/ldap.conf
echo "ldap:// ldaps:// ldapi://" >> /etc/ldap/ldap.conf
echo "TLS_CACERT /etc/ssl/slapd/cacert.pem" >> /etc/ldap/ldap.conf
echo "TLS_REQCERT allow" >> /etc/ldap/ldap.conf

echo "===== Install phpldapadmin ====="
# Install phpldapadmin
sudo apt-get -y install phpldapadmin

echo "===== Configure phpldapadmin ====="
# Backup existing config.php file for phpldapadmin and create a new one
cp /etc/phpldapadmin/config.php /etc/phpldapadmin/config.php.old
echo "<?php " > /etc/phpldapadmin/config.php
echo "\$servers = new Datastore();" >> /etc/phpldapadmin/config.php
echo "\$servers->newServer('ldap_pla');" >> /etc/phpldapadmin/config.php
echo "\$servers->setValue('server','name','$organization');" >> /etc/phpldapadmin/config.php
echo "\$servers->setValue('server','host','$domain');" >> /etc/phpldapadmin/config.php
echo "\$servers->setValue('server','base',array('$base'));" >> /etc/phpldapadmin/config.php
echo "\$servers->setValue('login','bind_id','cn=admin,$base');" >> /etc/phpldapadmin/config.php
echo "\$config->custom->appearance['hide_template_warning'] = true;" >> /etc/phpldapadmin/config.php
echo "\$servers->setValue('server','tls',true);" >> /etc/phpldapadmin/config.php
echo "?>" >> /etc/phpldapadmin/config.php

# Backup existing /usr/share/phpldapadmin/lib/TemplateRender.php and change password_hash to password_hash_custom (to take care of template error)
cp /usr/share/phpldapadmin/lib/TemplateRender.php /usr/share/phpldapadmin/lib/TemplateRender.php.old
sed -i "s/password_hash/password_hash_custom/" /usr/share/phpldapadmin/lib/TemplateRender.php

echo "===== Enable SSL on Apache ====="
a2enmod ssl

echo "===== edit default-ssl.conf ====="
sed -i '/^[[:space:]]*SSLCertificateFile[[:space:]]/ s/^.*/SSLCertificateFile \/etc\/ssl\/slapd\/ldaps_slapd_cert.pem/' /etc/apache2/sites-available/default-ssl.conf
sed -i '/^[[:space:]]*SSLCertificateKeyFile[[:space:]]/ s/^.*/SSLCertificateKeyFile \/etc\/ssl\/slapd\/ldaps_slapd_key.pem/' /etc/apache2/sites-available/default-ssl.conf

a2ensite default-ssl

echo "===== Set up master-master replication ====="

echo "===== Install ntp package ====="
apt-get -y install ntp
/etc/init.d/ntp restart

echo "===== Generate password ====="
# SLAPPASSWD=$(slappasswd -s $directoryadminpass)
SLAPPASSWD=$directoryadminpass
SLAPPASSWDEscaped="$(sed 's/[&/\]/\\&/g' <<< "$SLAPPASSWD")"

echo "===== Load syncProv module ====="
ldapmodify -Y EXTERNAL -H ldapi:/// -f config_1_loadSyncProvModule.ldif

echo "===== Set server ID ====="
sed -i "s/{serverID}/$index/" config_2_setServerID.ldif
ldapmodify -Y EXTERNAL -H ldapi:/// -f config_2_setServerID.ldif

echo "===== Set password ====="

sed -i "s@{password}@$SLAPPASSWDEscaped@" config_3_setConfigPW.ldif
ldapmodify -Y EXTERNAL -H ldapi:/// -f config_3_setConfigPW.ldif

echo "===== Add Root DN ====="
ldapmodify -Y EXTERNAL -H ldapi:/// -f config_3a_addOlcRootDN.ldif

echo "===== Add configuration replication ====="
for i in `seq 1 $vmCount`; do
    echo "olcServerID: $i ldap://ldap$i.$subdomain.local" >> config_4_addConfigReplication.ldif
done

ldapmodify -Y EXTERNAL -H ldapi:/// -f config_4_addConfigReplication.ldif

echo "===== Add syncProv to the configuration ====="
ldapmodify -Y EXTERNAL -H ldapi:/// -f config_5_addSyncProv.ldif

# Force TLS
ldapmodify -Y EXTERNAL -H ldapi:/// -f ./forceTLS.ldif

echo "===== Add syncRepl among servers ====="
syncRepl=""
for i in `seq 1 $vmCount`; do
    syncRepl=$syncRepl"olcSyncRepl: rid=00$i provider=ldap://ldap$i.$subdomain.local binddn=\"cn=admin,cn=config\" bindmethod=simple credentials=$SLAPPASSWDEscaped searchbase=\"cn=config\" type=refreshAndPersist retry=\"5 5 300 5\" timeout=1 starttls=critical tls_reqcert=allow\n"
done

sed -i "s@{syncRepl}@$syncRepl@" config_6_addSyncRepl.ldif
# ldapmodify -Y EXTERNAL -H ldapi:/// -f config_6_addSyncRepl.ldif
ldapmodify -ZZ -h $localdomain -D "cn=admin,cn=config" -w $SLAPPASSWD -f config_6_addSyncRepl.ldif

# test replication
# ldapmodify -Y EXTERNAL -H ldapi:/// -f config_7_testConfigReplication.ldif

# Since configuration is expected to be replicating at this point, we only need to do this on the first server.
if [ "$index" = "1" ]; then

    echo "===== Modify HDB config ====="

    echo "===== Add syncProv to HDB ====="
    # ldapmodify -Y EXTERNAL -H ldapi:/// -f hdb_1_addSyncProvToHDB.ldif
    ldapmodify -ZZ -h $localdomain -D "cn=admin,cn=config" -w $SLAPPASSWD -f hdb_1_addSyncProvToHDB.ldif

    echo "===== Add suffix ====="
    sed -i "s@{dn}@$base@" hdb_2_addOlcSuffix.ldif
    # ldapmodify -Y EXTERNAL -H ldapi:/// -f hdb_2_addOlcSuffix.ldif
    ldapmodify -ZZ -h $localdomain -D "cn=admin,cn=config" -w $SLAPPASSWD -f hdb_2_addOlcSuffix.ldif
    
    echo "===== Add Root DN ====="
    sed -i "s@{dn}@$base@" hdb_3_addOlcRootDN.ldif
    # ldapmodify -Y EXTERNAL -H ldapi:/// -f hdb_3_addOlcRootDN.ldif
    ldapmodify -ZZ -h $localdomain -D "cn=admin,cn=config" -w $SLAPPASSWD -f hdb_3_addOlcRootDN.ldif
    
    echo "===== Add Root password ====="
    sed -i "s@{password}@$SLAPPASSWDEscaped@" hdb_4_addOlcRootPW.ldif
    # ldapmodify -Y EXTERNAL -H ldapi:/// -f hdb_4_addOlcRootPW.ldif
    ldapmodify -ZZ -h $localdomain -D "cn=admin,cn=config" -w $SLAPPASSWD -f hdb_4_addOlcRootPW.ldif
    
    echo "===== Add  syncRepl among servers ====="
    for i in `seq 1 $vmCount`; do
        let "rid=i+vmCount"
        echo "olcSyncRepl: rid=10$rid provider=ldap://ldap$i.$subdomain.local binddn=\"cn=admin,$base\" bindmethod=simple credentials=$SLAPPASSWD searchbase=\"$base\" type=refreshAndPersist interval=00:00:00:10 retry=\"5 5 300 5\" timeout=1" >> hdb_5_addOlcSyncRepl.ldif
    done

    # ldapmodify -Y EXTERNAL -H ldapi:/// -f hdb_5_addOlcSyncRepl.ldif
    ldapmodify -ZZ -h $localdomain -D "cn=admin,cn=config" -w $SLAPPASSWD -f hdb_5_addOlcSyncRepl.ldif
    
    echo "===== Add mirror mode ====="
    # ldapmodify -Y EXTERNAL -H ldapi:/// -f hdb_6_addOlcMirrorMode.ldif
    ldapmodify -ZZ -h $localdomain -D "cn=admin,cn=config" -w $SLAPPASSWD -f hdb_6_addOlcMirrorMode.ldif
    
    echo "===== Add index to the database ====="
    # ldapmodify -Y EXTERNAL -H ldapi:/// -f hdb_7_addIndexHDB.ldif
    ldapmodify -ZZ -h $localdomain -D "cn=admin,cn=config" -w $SLAPPASSWD -f hdb_7_addIndexHDB.ldif
    
fi

echo "===== Restart Apache ====="
apachectl restart
