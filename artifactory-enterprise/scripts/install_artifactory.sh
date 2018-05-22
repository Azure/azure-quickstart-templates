#!/bin/bash

DB_URL=$1
DB_NAME=$2
DB_USER=$3
DB_PASSWORD=$4

STORAGE_ACCT=$5
STORAGE_CONTAINER=$6
STORAGE_ACCT_KEY=$7
ARTIFACTORY_VERSION=$8
MASTER_KEY=$9
IS_PRIMARY=$10

ARTIFACTORY_LICENSE_1=$11
ARTIFACTORY_LICENSE_2=$12
ARTIFACTORY_LICENSE_3=$13
ARTIFACTORY_LICENSE_4=$14
ARTIFACTORY_LICENSE_5=$15

export DEBIAN_FRONTEND=noninteractive

# install the wget and curl
apt-get update
apt-get -y install wget curl>> /tmp/install-curl.log 2>&1

# install Java 8
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
apt-get install -y oracle-java8-installer>> /tmp/install-java8.log 2>&1

#Generate Self-Signed Cert
mkdir -p /etc/pki/tls/private/ /etc/pki/tls/certs/
openssl req -nodes -x509 -newkey rsa:4096 -keyout /etc/pki/tls/private/example.key -out /etc/pki/tls/certs/example.pem -days 356 -subj "/C=US/ST=California/L=SantaClara/O=IT/CN=*.localhost"

# install the MySQL stack
echo "deb https://jfrog.bintray.com/artifactory-pro-debs trusty main" | tee -a /etc/apt/sources.list
curl https://bintray.com/user/downloadSubjectPublicKey?username=jfrog | apt-key add -
apt-get update
apt-get -y install nginx>> /tmp/install-nginx.log 2>&1
apt-get -y install jfrog-artifactory-pro=${ARTIFACTORY_VERSION} >> /tmp/install-artifactory.log 2>&1

#Install database drivers
curl -L -o  /opt/jfrog/artifactory/tomcat/lib/mysql-connector-java-5.1.38.jar https://bintray.com/artifact/download/bintray/jcenter/mysql/mysql-connector-java/5.1.38/mysql-connector-java-5.1.38.jar
curl -L -o  /opt/jfrog/artifactory/tomcat/lib/mssql-jdbc-6.2.1.jre8.jar https://bintray.com/artifact/download/bintray/jcenter/com/microsoft/sqlserver/mssql-jdbc/6.2.1.jre8/mssql-jdbc-6.2.1.jre8.jar
curl -L -o  /opt/jfrog/artifactory/tomcat/lib/postgresql-9.4.1212.jar https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar

CERTIFICATE_DOMAIN=$(cat /var/lib/cloud/instance/user-data.txt | grep "^CERTIFICATE_DOMAIN=" | sed "s/CERTIFICATE_DOMAIN=//")
[ -z "$CERTIFICATE_DOMAIN" ] && CERTIFICATE_DOMAIN=artifactory

ARTIFACTORY_SERVER_NAME=$(cat /var/lib/cloud/instance/user-data.txt | grep "^ARTIFACTORY_SERVER_NAME=" | sed "s/ARTIFACTORY_SERVER_NAME=//")
[ -z "$ARTIFACTORY_SERVER_NAME" ] && ARTIFACTORY_SERVER_NAME=artifactory

#Configuring nginx
rm /etc/nginx/sites-enabled/default

cat <<EOF >/etc/nginx/nginx.conf
  #user  nobody;
  worker_processes  1;
  error_log  /var/log/nginx/error.log  info;
  #pid        logs/nginx.pid;
  events {
    worker_connections  1024;
  }

  http {
    include       mime.types;
    include    /etc/nginx/conf.d/*.conf;
    default_type  application/octet-stream;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    '$status $body_bytes_sent "$http_referer" '
    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile        on;
    #tcp_nopush     on;
    #keepalive_timeout  0;
    keepalive_timeout  65;
    }
EOF

cat <<EOF >/etc/nginx/conf.d/artifactory.conf
ssl_certificate      /etc/pki/tls/certs/cert.pem;
ssl_certificate_key  /etc/pki/tls/private/cert.key;
ssl_session_cache shared:SSL:1m;
ssl_prefer_server_ciphers   on;
## server configuration
server {
  listen 443 ssl;
  listen 80 ;
  server_name ~(?<repo>.+)\\.${CERTIFICATE_DOMAIN} artifactory ${ARTIFACTORY_SERVER_NAME}.${CERTIFICATE_DOMAIN};
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

cat <<EOF >/var/opt/jfrog/artifactory/etc/artifactory.cluster.license
${ARTIFACTORY_LICENSE_1}

${ARTIFACTORY_LICENSE_2}

${ARTIFACTORY_LICENSE_3}

${ARTIFACTORY_LICENSE_4}

${ARTIFACTORY_LICENSE_5}
EOF

cat <<EOF >/var/opt/jfrog/artifactory/etc/ha-node.properties
node.id=art1
artifactory.ha.data.dir=/var/opt/jfrog/artifactory/data
context.url=http://127.0.0.1:8081/artifactory
membership.port=10001
hazelcast.interface=172.25.0.3
primary=${IS_PRIMARY}
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
    <chain>
       <provider id="cache-fs-eventual-azure-blob-storage" type="cache-fs">
           <provider id="sharding-cluster-eventual-azure-blob-storage" type="sharding-cluster">
               <sub-provider id="eventual-cluster-azure-blob-storage" type="eventual-cluster">
                   <provider id="retry-azure-blob-storage" type="retry">
                       <provider id="azure-blob-storage" type="azure-blob-storage"/>
                   </provider>
               </sub-provider>
               <dynamic-provider id="remote-azure-blob-storage" type="remote"/>
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

HOSTNAME=$(hostname -i)
sed -i -e "s/art1/art-$(date +%s$RANDOM)/" /var/opt/jfrog/artifactory/etc/ha-node.properties
sed -i -e "s/127.0.0.1/$HOSTNAME/" /var/opt/jfrog/artifactory/etc/ha-node.properties
sed -i -e "s/172.25.0.3/$HOSTNAME/" /var/opt/jfrog/artifactory/etc/ha-node.properties

cat /var/lib/cloud/instance/user-data.txt | grep "^CERTIFICATE=" | sed "s/CERTIFICATE=//" > /tmp/temp.pem
cat /tmp/temp.pem | sed 's/CERTIFICATE----- /&\n/g' | sed 's/ -----END/\n-----END/g' | awk '{if($0 ~ /----/) {print;} else { gsub(/ /,"\n");print;}}' > /etc/pki/tls/certs/cert.pem
rm /tmp/temp.pem

cat /var/lib/cloud/instance/user-data.txt | grep "^CERTIFICATE_KEY=" | sed "s/CERTIFICATE_KEY=//" > /tmp/temp.key
cat /tmp/temp.key | sed 's/KEY----- /&\n/' | sed 's/ -----END/\n-----END/' | awk '{if($0 ~ /----/) {print;} else { gsub(/ /,"\n");print;}}' > /etc/pki/tls/private/cert.key
rm /tmp/temp.key

echo "artifactory.ping.allowUnauthenticated=true" >> /var/opt/jfrog/artifactory/etc/artifactory.system.properties
EXTRA_JAVA_OPTS=$(cat /var/lib/cloud/instance/user-data.txt | grep "^EXTRA_JAVA_OPTS=" | sed "s/EXTRA_JAVA_OPTS=//")
[ -z "$EXTRA_JAVA_OPTS" ] && EXTRA_JAVA_OPTS='-server -Xms2g -Xmx12g -Xss256k -XX:+UseG1GC -XX:OnOutOfMemoryError="kill -9 %p"'
echo "export JAVA_OPTIONS=\"${EXTRA_JAVA_OPTS}\"" >> /var/opt/jfrog/artifactory/etc/default
chown artifactory:artifactory -R /var/opt/jfrog/artifactory/*  && chown artifactory:artifactory -R /var/opt/jfrog/artifactory/etc/security && chown artifactory:artifactory -R /var/opt/jfrog/artifactory/etc/*

# start Artifactory
sleep $((RANDOM % 120))
service artifactory start
service nginx start
nginx -s reload
