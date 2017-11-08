domain=$1
location=$2
SITENAME=$1.$2.cloudapp.azure.com

INSTALLDIR=/opt/shibboleth-idp

apt-get -y update

echo "==============>Printing values of all variables"
echo "domain"
echo $domain
echo "location"
echo $location
echo "Sitename"
echo $SITENAME
echo "==============>Install JDK 8"
add-apt-repository -y ppa:webupd8team/java
apt-get -y update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
apt-get -y install oracle-java8-installer

export JAVA_HOME=/usr/lib/jvm/java-8-oracle
echo JAVA_HOME='"'$JAVA_HOME'"' >> /etc/environment
source /etc/environment

apt-get -y install tomcat8
echo "==============>Configuring SSL for Tomcat8"
SSLKEYPASSWORD=$(openssl rand -base64 12)
service tomcat8 restart

mkdir /usr/share/tomcat8/keystore
keytool -genkey -alias tomcat -keyalg RSA -keystore /usr/share/tomcat8/keystore/server.keystore -keysize 2048 -storepass $SSLKEYPASSWORD -keypass $SSLKEYPASSWORD -dname "cn=testname, ou=shibbolethOU, o=shibbolethO, c=US"
sed -i '/redirectPort="8443"/a  <Connector port="8443"  protocol="org.apache.coyote.http11.Http11NioProtocol" SSLEnabled="true" maxThreads="150" scheme="https" secure="true"  clientAuth="false" sslProtocol="TLS" address="0.0.0.0" keystoreFile="/\usr/\share\/tomcat8/\keystore/\server.keystore" keystorePass="'$SSLKEYPASSWORD'"/>' /var/lib/tomcat8/conf/server.xml

service tomcat8 restart
