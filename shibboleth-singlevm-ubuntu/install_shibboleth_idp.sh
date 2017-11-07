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

add-apt-repository -y ppa:webupd8team/java
apt-get -y update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
apt-get -y install oracle-java8-installer

export JAVA_HOME=/usr/lib/jvm/java-8-oracle
echo JAVA_HOME='"'$JAVA_HOME'"' >> /etc/environment
source /etc/environment

apt-get -y install tomcat7
echo "==============>Configuring SSL for Tomcat7"
SSLKEYPASSWORD=$(openssl rand -base64 12)

mkdir /usr/share/tomcat7/keystore
keytool -genkey -alias tomcat -keyalg RSA -keystore /usr/share/tomcat7/keystore/server.keystore -keysize 2048 -storepass $SSLKEYPASSWORD -keypass $SSLKEYPASSWORD -dname "cn=testname, ou=shibbolethOU, o=shibbolethO, c=US"

sed -i '/redirectPort="8443"/a  <Connector port="8443"  protocol="org.apache.coyote.http11.Http11NioProtocol"  maxThreads="150" SSLEnabled="true" scheme="https" secure="true" keystoreFile="/usr/share/tomcat8/keystore/server.keystore" keystorePass="fU6zrxfVdLSg9sCB" address="0.0.0.0"
               clientAuth="false" sslProtocol="TLS"/>' /var/lib/tomcat7/conf/server.xml			   
sed -i 's|java-7-oracle"|java-8-oracle  /usr/lib/jvm/java-6-oracle" |' /etc/init.d/tomcat7
service tomcat7 restart
