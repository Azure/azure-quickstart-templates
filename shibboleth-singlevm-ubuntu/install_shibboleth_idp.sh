domain=$1
location=$2
SITENAME=$1.$2.cloudapp.azure.com

INSTALLDIR=/opt/shibboleth-idp

apt-get -y update
apt-get -y upgrade
apt-get -y install unzip
apt-get -y install tomcat8

SSLKEYPASSWORD=$(openssl rand -base64 12)

mkdir /usr/share/tomcat8/keystore
keytool -genkey -alias tomcat -keyalg RSA -keystore /usr/share/tomcat8/keystore/server.keystore -keysize 2048 -storepass $SSLKEYPASSWORD -keypass $SSLKEYPASSWORD -dname "cn=testname, ou=shibbolethOU, o=shibbolethO, c=US"
sed -i '/redirectPort="8443"/a  <Connector port="8443"  protocol="org.apache.coyote.http11.Http11NioProtocol" SSLEnabled="true" maxThreads="150" scheme="https" secure="true"  clientAuth="false" sslProtocol="TLS" address="0.0.0.0" keystoreFile="/\usr/\share\/tomcat8/\keystore/\server.keystore" keystorePass="'$SSLKEYPASSWORD'"/>' /var/lib/tomcat8/conf/server.xml

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
echo JAVA_HOME='"'$JAVA_HOME'"' >> /etc/environment
source /etc/environment

echo export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64 >> /etc/profile
echo export CATALINA_HOME=/var/lib/tomcat8 >> /etc/profile
source /etc/profile


sed -i 's,</tomcat-users>,  <role rolename="manager-gui"/>\n  <user username="admin" password="secret" roles="manager-gui"/>  \n</tomcat-users>,g'   /var/lib/tomcat8/conf/tomcat-users.xml

#Change 128m to 512m
sed -i 's/128m/512m/g'  /etc/default/tomcat8

touch /etc/authbind/byport/8443
chmod 0755 /etc/authbind/byport/8443
chown tomcat8:tomcat8 /etc/authbind/byport/8443


SCOPE=$(hostname -f)

cd /usr/share

# install Shibboleth
wget http://shibboleth.net/downloads/identity-provider/3.3.2/shibboleth-identity-provider-3.3.2.zip -O shibboleth.zip
unzip shibboleth.zip

cd shibboleth-identity-provider-3.3.2
chmod -R +x bin

echo "idp.sealer.password = $(openssl rand -base64 12)" >credentials.properties
chmod 0600 credentials.properties

cat >temp.properties <<EOF
idp.additionalProperties= /conf/ldap.properties, /conf/saml-nameid.properties, /conf/services.properties, /conf/credentials.properties
idp.sealer.storePassword= %{idp.sealer.password}
idp.sealer.keyPassword= %{idp.sealer.password}
idp.signing.key= %{idp.home}/credentials/idp.key
idp.signing.cert= %{idp.home}/credentials/idp.crt
idp.encryption.key= %{idp.home}/credentials/idp.key
idp.encryption.cert= %{idp.home}/credentials/idp.crt
idp.entityID= https://$SITENAME:8443/idp/shibboleth
idp.scope= $SCOPE
idp.consent.StorageService= shibboleth.JPAStorageService
idp.consent.userStorageKey= shibboleth.consent.AttributeConsentStorageKey
idp.consent.userStorageKeyAttribute= %{idp.persistentId.sourceAttribute}
idp.consent.allowGlobal= true
idp.consent.compareValues= true
idp.consent.maxStoredRecords= -1
idp.ui.fallbackLanguages= en,de,fr
EOF

echo "==============> Running the installer"

# run the installer
SRCDIR=$(pwd)

bash bin/install.sh \
-Didp.relying.party.present= \
-Didp.src.dir=. \
-Didp.target.dir=$INSTALLDIR \
-Didp.merge.properties=temp.properties \
-Didp.sealer.password=$(cut -d " " -f3 <credentials.properties) \
-Didp.keystore.password= \
-Didp.conf.filemode=644 \
-Didp.host.name=$SITENAME \
-Didp.scope=$SITENAME

chown -R tomcat8 /opt/shibboleth-idp

cd /opt/shibboleth-idp/edit-webapp/WEB-INF/lib

echo "==============>Adding JSTL to Tomcat8"

wget https://build.shibboleth.net/nexus/service/local/repositories/thirdparty/content/javax/servlet/jstl/1.2/jstl-1.2.jar
chmod 777 jstl-1.2.jar
chown tomcat8 jstl-1.2.jar

sed -i -e 's,https://'"$SITENAME"'/idp/profile/Shibboleth/SSO,https://'"$SITENAME"':8443/idp/profile/Shibboleth/SSO,g' /opt/shibboleth-idp/metadata/idp-metadata.xml
sed -i -e 's,https://'"$SITENAME"'/idp/profile/SAML2/POST/SSO,https://'"$SITENAME"':8443/idp/profile/SAML2/POST/SSO,g' /opt/shibboleth-idp/metadata/idp-metadata.xml
sed -i -e 's,https://'"$SITENAME"'/idp/profile/SAML2/POST-SimpleSign/SSO,https://'"$SITENAME"':8443/idp/profile/SAML2/POST-SimpleSign/SSO,g' /opt/shibboleth-idp/metadata/idp-metadata.xml
sed -i -e 's,https://'"$SITENAME"'/idp/profile/SAML2/Redirect/SSO,https://'"$SITENAME"':8443/idp/profile/SAML2/Redirect/SSO,g' /opt/shibboleth-idp/metadata/idp-metadata.xml

echo "<Context docBase=\"/opt/shibboleth-idp/war/idp.war\" privileged=\"true\" antiResourceLocking=\"false\" antijarLocking=\"false\" unpackWar=\"false\" swallowOutput=\"true\" />" > /var/lib/tomcat8/conf/Catalina/localhost/idp.xml

mv  /usr/share/shibboleth-identity-provider-3.3.2/credentials.properties $INSTALLDIR/conf

cd /opt/shibboleth-idp
echo -e "\nCreating self-signed certificate..."
bin/keygen.sh --lifetime 3 \
--certfile $INSTALLDIR/credentials/idp.crt \
--keyfile $INSTALLDIR/credentials/idp.key \
--hostname $SITENAME \
--uriAltName https://$SITENAME:8443/idp/shibboleth
echo ...done
chmod 600 $INSTALLDIR/credentials/idp.key


getent passwd tomcat8 >/dev/null && TCUSER=tomcat8 || TCUSER=tomcat
chown $TCUSER $INSTALLDIR/credentials/idp.key
chown $TCUSER $INSTALLDIR/credentials/sealer.*
chown $TCUSER $INSTALLDIR/metadata
chown $TCUSER $INSTALLDIR/logs
chown $TCUSER $INSTALLDIR/conf/credentials.properties

#allow access to public
sed -i -e "s~'::1/128'~'::1/128', '0.0.0.0/0'~g" /opt/shibboleth-idp/conf/access-control.xml

bin/build.sh -Didp.target.dir=/opt/shibboleth-idp

service tomcat8 restart
