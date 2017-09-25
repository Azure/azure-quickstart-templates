#!/bin/bash

db_url=$1
db_name=$2
db_user=$3
db_password=$4

storage_acct=$5
storage_container=$6
storage_acct_key=$7

echo "DB Host = $db_url and $db_name and $db_user and $db_password">> /tmp/dbhost.log 2>&1
export DEBIAN_FRONTEND=noninteractive

# install the LAMP stack
apt-get -y install wget curl>> /tmp/yum-install.log 2>&1

# install Java 8
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
apt-get install -y oracle-java8-installer>> /tmp/yum-java8.log 2>&1

#Generate Self-Signed Cert
mkdir -p /etc/pki/tls/private/ /etc/pki/tls/certs/
openssl req -nodes -x509 -newkey rsa:4096 -keyout /etc/pki/tls/private/example.key -out /etc/pki/tls/certs/example.pem -days 356 -subj "/C=US/ST=California/L=SantaClara/O=IT/CN=localhost"

# install the MySQL stack
echo "deb https://jfrog.bintray.com/artifactory-pro-debs trusty main" | tee -a /etc/apt/sources.list
curl https://bintray.com/user/downloadSubjectPublicKey?username=jfrog | apt-key add -
apt-get update
apt-get -y install nginx>> /tmp/yum-nginx.log 2>&1
apt-get -y install jfrog-artifactory-pro>> /tmp/yum-artifactory.log 2>&1

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
## server configuration
  server {
    listen 5001 ssl;
    server_name artifactory;
    if (\$http_x_forwarded_proto = '') {
      set \$http_x_forwarded_proto  \$scheme;
    }
    ## Application specific logs
    ## access_log /var/log/nginx/artifactory-access.log timing;
    ## error_log /var/log/nginx/artifactory-error.log;
    rewrite ^/(v1|v2)/(.*) /artifactory/api/docker/docker/\$1/\$2;
    chunked_transfer_encoding on;
    client_max_body_size 0;
    location /artifactory/ {
    proxy_read_timeout  900;
    proxy_pass_header   Server;
    proxy_cookie_path   ~*^/.* /;
    proxy_pass          http://127.0.0.1:8081/artifactory/;
    proxy_set_header    X-Artifactory-Override-Base-Url \$http_x_forwarded_proto://\$host:\$server_port/artifactory;
    proxy_set_header    X-Forwarded-Port  \$server_port;
    proxy_set_header    X-Forwarded-Proto \$http_x_forwarded_proto;
    proxy_set_header    Host              \$http_host;
    proxy_set_header    X-Forwarded-For   \$proxy_add_x_forwarded_for;
  }
}
EOF

#cat <<EOF >/var/opt/jfrog/artifactory/etc/db.properties
#type=mssql
#driver=com.microsoft.sqlserver.jdbc.SQLServerDriver
#url=${db_url};databaseName=${db_name};sendStringParametersAsUnicode=false;applicationName=Artifactory Binary Repository
#username=${db_user}
#password=${db_password}
#EOF

#cat <<EOF >/var/opt/jfrog/artifactory/etc/binarystore.xml
#<config version="1">
#    <chain template="azure-blob-storage"/>
#    <provider id="azure-blob-storage" type="azure-blob-storage">
#        <accountName>${storage_acct}</accountName>
#        <accountKey>${storage_acct_key}</accountKey>
#        <endpoint>https://${storage_acct}.blob.core.windows.net/</endpoint>
#        <containerName>${storage_container}</containerName>
#    </provider>
#</config>
#EOF

chown artifactory:artifactory -R /var/opt/jfrog/artifactory/*  && chown artifactory:artifactory -R /var/opt/jfrog/artifactory/etc/security

# start Artifactory
service artifactory start
service nginx start
nginx -s reload
