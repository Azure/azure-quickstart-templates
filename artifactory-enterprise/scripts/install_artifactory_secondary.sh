#!/bin/bash

DB_URL=$1
DB_NAME=$2
DB_USER=$3
DB_PASSWORD=$4

STORAGE_ACCT=$5
STORAGE_CONTAINER=$6
STORAGE_ACCT_KEY=$7
MASTER_KEY=$8
ARTIFACTORY_VERSION=$9
# EXTRA_JAVA_OPTS=$9

export DEBIAN_FRONTEND=noninteractive

# install the wget and curl
apt-get update
apt-get -y install wget curl>> /tmp/yum-install.log 2>&1

# install Java 8
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
apt-get install -y oracle-java8-installer>> /tmp/yum-java8.log 2>&1

#Generate Self-Signed Cert
mkdir -p /etc/pki/tls/private/ /etc/pki/tls/certs/
openssl req -nodes -x509 -newkey rsa:4096 -keyout /etc/pki/tls/private/example.key -out /etc/pki/tls/certs/example.pem -days 356 -subj "/C=US/ST=California/L=SantaClara/O=IT/CN=*.localhost"

# install the MySQL stack
echo "deb https://jfrog.bintray.com/artifactory-pro-debs trusty main" | tee -a /etc/apt/sources.list
curl https://bintray.com/user/downloadSubjectPublicKey?username=jfrog | apt-key add -
apt-get update
apt-get -y install nginx>> /tmp/yum-nginx.log 2>&1
apt-get -y install jfrog-artifactory-pro=${ARTIFACTORY_VERSION} >> /tmp/yum-artifactory.log 2>&1

#Install database drivers
curl -L -o  /opt/jfrog/artifactory/tomcat/lib/mysql-connector-java-5.1.38.jar https://bintray.com/artifact/download/bintray/jcenter/mysql/mysql-connector-java/5.1.38/mysql-connector-java-5.1.38.jar
curl -L -o  /opt/jfrog/artifactory/tomcat/lib/mssql-jdbc-6.2.1.jre8.jar https://bintray.com/artifact/download/bintray/jcenter/com/microsoft/sqlserver/mssql-jdbc/6.2.1.jre8/mssql-jdbc-6.2.1.jre8.jar
curl -L -o  /opt/jfrog/artifactory/tomcat/lib/postgresql-9.4.1212.jar https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar

#Configuring nginx
rm /etc/nginx/sites-enabled/default

cat <<EOF >/etc/nginx/conf.d/artifactory.conf
ssl_certificate      /etc/pki/tls/certs/example.pem;
ssl_certificate_key  /etc/pki/tls/private/example.key;
ssl_session_cache shared:SSL:1m;
ssl_prefer_server_ciphers   on;
## server configuration
server {
  listen 443 ssl;
  listen 80 ;
  server_name ~(?<repo>.+)\\.artifactory artifactory;
  if (\$http_x_forwarded_proto = '') {
    set \$http_x_forwarded_proto  \$scheme;
  }
  ## Application specific logs
  ## access_log /var/log/nginx/artifactory-access.log timing;
  ## error_log /var/log/nginx/artifactory-error.log;
  rewrite ^/$ /artifactory/webapp/ redirect;
  rewrite ^/artifactory/?(/webapp)?$ /artifactory/webapp/ redirect;
  rewrite ^/(v1|v2)/(.*) /artifactory/api/docker/\$repo/\$1/\$2;
  chunked_transfer_encoding on;
  client_max_body_size 0;
  location /artifactory/ {
    proxy_read_timeout  900;
    proxy_pass_header   Server;
    proxy_cookie_path   ~*^/.* /;
    proxy_pass          http://127.0.0.1:8081/artifactory/;
    proxy_set_header    X-Artifactory-Override-Base-Url
    \$http_x_forwarded_proto://\$host:\$server_port/artifactory;
    proxy_set_header    X-Forwarded-Port  \$server_port;
    proxy_set_header    X-Forwarded-Proto \$http_x_forwarded_proto;
    proxy_set_header    Host              \$http_host;
    proxy_set_header    X-Forwarded-For   \$proxy_add_x_forwarded_for;
   }
}
EOF

cat <<EOF >/var/opt/jfrog/artifactory/etc/ha-node.properties
node.id=art1
artifactory.ha.data.dir=/var/opt/jfrog/artifactory/data
context.url=http://127.0.0.1:8081/artifactory
membership.port=10001
hazelcast.interface=172.25.0.3
primary=false
EOF

cat <<EOF >/var/opt/jfrog/artifactory/etc/db.properties
type=mssql
driver=com.microsoft.sqlserver.jdbc.SQLServerDriver
url=${DB_URL};databaseName=${DB_NAME};sendStringParametersAsUnicode=false;applicationName=Artifactory Binary Repository
username=${DB_USER}
password=${DB_PASSWORD}
EOF

mkdir -p /var/opt/jfrog/artifactory/etc/security

cat <<EOF >/var/opt/jfrog/artifactory/etc/security/master.key
  ${MASTER_KEY}
EOF

cat <<EOF >/var/opt/jfrog/artifactory/etc/binarystore.xml
<config version="2">
    <chain template=“cluster-azure-blob-storage”>
       <provider id=“cache-fs-eventual-azure-blob-storage” type=“cache-fs”>
           <provider id=“sharding-cluster-eventual-azure-blob-storage” type=“sharding-cluster”>
               <sub-provider id=“eventual-cluster-azure-blob-storage” type=“eventual-cluster”>
                   <provider id=“retry-azure-blob-storage” type=“retry”>
                       <provider id=“azure-blob-storage” type=“azure-blob-storage”/>
                   </provider>
               </sub-provider>
               <dynamic-provider id=“remote-azure-blob-storage” type=“remote”/>
           </provider>
       </provider>
   </chain>

    <!-- cluster eventual Azure Blob Storage Service default chain -->
    <provider id="sharding-cluster-eventual-azure-blob-storage" type="sharding-cluster">
        <readBehavior>crossNetworkStrategy</readBehavior>
        <writeBehavior>crossNetworkStrategy</writeBehavior>
        <redundancy>2</redundancy>
        <lenientLimit>1</lenientLimit>
        <property name="zones" value="local,remote"/>
    </provider>

    <provider id="remote-azure-blob-storage" type="remote">
        <zone>remote</zone>
    </provider>

    <provider id="eventual-cluster-azure-blob-storage" type="eventual-cluster">
        <zone>local</zone>
    </provider>

    <!--cluster eventual template-->
    <provider id="azure-blob-storage" type="azure-blob-storage">
        <accountName>${STORAGE_ACCT}</accountName>
        <accountKey>${STORAGE_ACCT_KEY}</accountKey>
        <endpoint>https://${STORAGE_ACCT}.blob.core.windows.net/</endpoint>
        <containerName>${STORAGE_CONTAINER}</containerName>
    </provider>
</config>
EOF

#cat /etc/pki/tls/certs/result.pem | sed 's/CERTIFICATE----- /CERTIFICATE-----\n/g' | sed 's/-----END/\n-----END/' > temp.pem
#mv -f temp.pem /etc/pki/tls/certs/cert.pem
#cat /etc/pki/tls/private/result.key | sed 's/KEY----- /KEY-----\n/g' | sed 's/-----END/\n-----END/'  > temp.key
#mv -f temp.key /etc/pki/tls/private/cert.key
#echo "artifactory.ping.allowUnauthenticated=true" >> /var/opt/jfrog/artifactory/etc/artifactory.system.properties
#echo "export JAVA_OPTIONS=\"${EXTRA_JAVA_OPTS}\"" >> /var/opt/jfrog/artifactory/etc/default
HOSTNAME=$(hostname -i)
sed -i -e "s/art1/art-$(date +%s$RANDOM)/" /var/opt/jfrog/artifactory/etc/ha-node.properties
sed -i -e "s/127.0.0.1/$HOSTNAME/" /var/opt/jfrog/artifactory/etc/ha-node.properties
sed -i -e "s/172.25.0.3/$HOSTNAME/" /var/opt/jfrog/artifactory/etc/ha-node.properties
chown artifactory:artifactory -R /var/opt/jfrog/artifactory/*  && chown artifactory:artifactory -R /var/opt/jfrog/artifactory/etc/security && chown artifactory:artifactory -R /var/opt/jfrog/artifactory/etc/*

# start Artifactory
sleep $((RANDOM % 120))
service artifactory start
service nginx start
nginx -s reload
