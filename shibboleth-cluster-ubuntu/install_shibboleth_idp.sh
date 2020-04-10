domain=$1
location=$2
dbdomain=$3
mySqlUser=$4
mySqlPasswordForUser=$5

SITENAME=$1.$2.cloudapp.azure.com
DBSITENAME=$3.$2.cloudapp.azure.com

INSTALLDIR=/opt/shibboleth-idp

apt-get -y update

echo "==============>Printing values of all variables"
echo "domain"
echo $domain
echo "location"
echo $location
echo "Sitename"
echo $SITENAME


#install Oracle JDK 7
echo debconf shared/accepted-oracle-license-v1-1 select true | \
sudo debconf-set-selections

echo debconf shared/accepted-oracle-license-v1-1 seen true | \
sudo debconf-set-selections

echo "==============>Installing JDK 8"

apt-get -y install python-software-properties
add-apt-repository -y ppa:webupd8team/java
apt-get -y update
apt-get -y install oracle-java8-installer


#install Tomcat 8

echo "==============>Installing tomcat8"

apt-get -y install tomcat8
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export PATH=$PATH:$JAVA_HOME/bin
export JRE_HOME=/usr/lib/jvm/java-8-oracle/jre
export JAVA_OPTS="-XX:+AggressiveOpts -Xms256m -Xmx512m -XX:MaxPermSize=256m -XX:+DisableExplicitGC"

sed -i 's/#AUTHBIND=no/AUTHBIND=yes/g' /etc/default/tomcat8

#generating the self signed SSL certificate for tomcat8

echo "==============>Configuring SSL for tomcat8"

mkdir /usr/share/tomcat8/keystore
cd $JAVA_HOME/bin

SSLKEYPASSWORD=$(openssl rand -base64 12)

keytool -genkey -alias tomcat -keyalg RSA -keystore /usr/share/tomcat8/keystore/server.keystore -keysize 2048 -storepass $SSLKEYPASSWORD -keypass $SSLKEYPASSWORD -dname "cn=$SITENAME, ou=shibbolethOU, o=shibbolethO, c=US"
sed -i -e 's,redirectPort="8443",redirectPort="8443" address="0.0.0.0",g' /var/lib/tomcat8/conf/server.xml
sed -i '/redirectPort="8443"/a  <Connector port="8443" protocol="HTTP/1.1" SSLEnabled="true" maxThreads="150" scheme="https" secure="true"  clientAuth="false" sslProtocol="TLS" address="0.0.0.0" keystoreFile="/\usr/\share\/tomcat8/\keystore/\server.keystore" keystorePass="'$SSLKEYPASSWORD'"/>' /var/lib/tomcat8/conf/server.xml


#download jstl as it is not distributed with tomcat8 and is required by Shibboleth

echo "==============>Adding JSTL to tomcat8"

cd /usr/share/tomcat8/lib
wget http://central.maven.org/maven2/jstl/jstl/1.2/jstl-1.2.jar
chmod 777 jstl-1.2.jar

#START Shibboleth installation

echo "==============> Start Shibboleth installation"
echo "==============> Download Shibboleth"

# install Shibboleth
wget http://shibboleth.net/downloads/identity-provider/3.3.3/shibboleth-identity-provider-3.3.3.zip -O shibboleth.zip
jar -xf shibboleth.zip

cd shibboleth-identity-provider-3.3.3
chmod -R +x bin

# generate a password for client-side encryption
echo "idp.sealer.password = $(openssl rand -base64 12)" >credentials.properties
chmod 0600 credentials.properties

# preconfigure settings for a typical deployment

echo "==============> Generate preconfig file"

cat >temp.properties <<EOF
idp.additionalProperties= /conf/ldap.properties, /conf/saml-nameid.properties, /conf/services.properties, /conf/credentials.properties
idp.sealer.storePassword= %{idp.sealer.password}
idp.sealer.keyPassword= %{idp.sealer.password}
idp.signing.key= %{idp.home}/credentials/idp.key
idp.signing.cert= %{idp.home}/credentials/idp.crt
idp.encryption.key= %{idp.home}/credentials/idp.key
idp.encryption.cert= %{idp.home}/credentials/idp.crt
idp.entityID= https://$SITENAME/idp/shibboleth
idp.scope= $SITENAME
idp.consent.StorageService= shibboleth.JPAStorageService
idp.consent.userStorageKey= shibboleth.consent.AttributeConsentStorageKey
idp.consent.userStorageKeyAttribute= %{idp.persistentId.sourceAttribute}
idp.consent.allowGlobal= false
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

chown -R tomcat8 /opt/shibboleth-idp/

#edit all location's port 8443 /opt/shibboleth-idp/metadata/idp.metadata
echo "==============> Updating the urls in metadata.xml"

sed -i -e 's,https://'"$SITENAME"'/idp/profile/Shibboleth/SSO,https://'"$SITENAME"':8443/idp/profile/Shibboleth/SSO,g' /opt/shibboleth-idp/metadata/idp-metadata.xml
sed -i -e 's,https://'"$SITENAME"'/idp/profile/SAML2/POST/SSO,https://'"$SITENAME"':8443/idp/profile/SAML2/POST/SSO,g' /opt/shibboleth-idp/metadata/idp-metadata.xml
sed -i -e 's,https://'"$SITENAME"'/idp/profile/SAML2/POST-SimpleSign/SSO,https://'"$SITENAME"':8443/idp/profile/SAML2/POST-SimpleSign/SSO,g' /opt/shibboleth-idp/metadata/idp-metadata.xml
sed -i -e 's,https://'"$SITENAME"'/idp/profile/SAML2/Redirect/SSO,https://'"$SITENAME"':8443/idp/profile/SAML2/Redirect/SSO,g' /opt/shibboleth-idp/metadata/idp-metadata.xml

# Use context deployment fragment for deploying idp.war file
echo "==============> Adding application to tomcat8"

echo "<Context docBase=\"/opt/shibboleth-idp/war/idp.war\" privileged=\"true\" antiresourcelocking=\"false\" antijarlocking=\"false\" unpackwar=\"false\" swallowoutput=\"true\" />" > /var/lib/tomcat8/conf/Catalina/localhost/idp.xml
mv credentials.properties $INSTALLDIR/conf

echo -e "\nCreating self-signed certificate..."
bin/keygen.sh --lifetime 3 \
--certfile $INSTALLDIR/credentials/idp.crt \
--keyfile $INSTALLDIR/credentials/idp.key \
--hostname $SITENAME \
--uriAltName https://$SITENAME/idp/shibboleth
echo ...done
chmod 600 $INSTALLDIR/credentials/idp.key

# set owner of key file and directories
getent passwd tomcat8 >/dev/null && TCUSER=tomcat8 || TCUSER=tomcat
chown $TCUSER $INSTALLDIR/credentials/idp.key
chown $TCUSER $INSTALLDIR/credentials/sealer.*
chown $TCUSER $INSTALLDIR/metadata
chown $TCUSER $INSTALLDIR/logs
chown $TCUSER $INSTALLDIR/conf/credentials.properties

#allow access to public
sed -i -e "s~'::1/128'~'::1/128', '0.0.0.0/0'~g" /opt/shibboleth-idp/conf/access-control.xml

#add beans shibboleth.JPAStorageService, shibboleth.JPAStorageService.EntityManagerFactory, shibboleth.JPAStorageService.JPAVendorAdapter & shibboleth.JPAStorageService.DataSource
sed -i -e 's~</beans>~<bean id=\"shibboleth.JPAStorageService\" class=\"org.opensaml.storage.impl.JPAStorageService\" p:cleanupInterval=\"%{idp.storage.cleanupInterval:PT10M}\" c:factory-ref=\"shibboleth.JPAStorageService.entityManagerFactory\" /> <bean id=\"shibboleth.JPAStorageService.entityManagerFactory\" class=\"org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean\"> <property name=\"packagesToScan\" value=\"org.opensaml.storage.impl\"/> <property name=\"dataSource\" ref=\"shibboleth.JPAStorageService.DataSource\"/> <property name=\"jpaVendorAdapter\" ref=\"shibboleth.JPAStorageService.JPAVendorAdapter\"/> <property name=\"jpaDialect\"> <bean class=\"org.springframework.orm.jpa.vendor.HibernateJpaDialect\" /> </property> </bean> <bean id=\"shibboleth.JPAStorageService.JPAVendorAdapter\" class=\"org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter\"> <property name=\"database\" value=\"MYSQL\" /> </bean> <bean	id=\"shibboleth.JPAStorageService.DataSource\" class=\"org.apache.tomcat.jdbc.pool.DataSource\" destroy-method=\"close\" lazy-init=\"true\" p:driverClassName=\"com.mysql.jdbc.Driver\" p:url=\"jdbc:mysql://'"$DBSITENAME"':3306/idp_db?autoReconnect=true\&amp;sessionVariables=wait_timeout=31536000\" p:validationQuery=\"SELECT 1;\" p:username=\"'"$mySqlUser"'\" p:password=\"'"$mySqlPasswordForUser"'\" /> </beans>~g' /opt/shibboleth-idp/conf/global.xml

sed -i "s/#idp.session.StorageService.*/idp.session.StorageService = shibboleth.JPAStorageService/" /opt/shibboleth-idp/conf/idp.properties
sed -i "s/#idp.consent.StorageService.*/idp.consent.StorageService = shibboleth.JPAStorageService/" /opt/shibboleth-idp/conf/idp.properties
sed -i "s/#idp.replayCache.StorageService.*/idp.replayCache.StorageService = shibboleth.JPAStorageService/" /opt/shibboleth-idp/conf/idp.properties
sed -i "s/#idp.artifact.StorageService.*/idp.artifact.StorageService = shibboleth.JPAStorageService/" /opt/shibboleth-idp/conf/idp.properties

#add mysql-connector-java.jar in /tomcat8/lib
cd /usr/share/tomcat8/lib
wget http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.6/mysql-connector-java-5.1.6.jar

#restart tomcat
service tomcat8 restart
