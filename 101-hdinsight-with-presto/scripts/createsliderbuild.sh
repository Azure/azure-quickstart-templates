#!/bin/bash

rm -rf build
mkdir build
cd build

wget https://github.com/prestodb/presto-yarn/archive/master.tar.gz -O presto-yarn.tar.gz
tar xzf presto-yarn.tar.gz
mvn -Dpresto.version=0.163 clean package -f presto-yarn-master/pom.xml
unzip presto-yarn-master/presto-yarn-package/target/presto-yarn-package-*.zip -d presto-yarn-package
tar xzf presto-yarn-package/package/files/presto-server-*.tar.gz

wget https://github.com/dharmeshkakadia/presto-hadoop-apache2/archive/master.tar.gz -O presto-hadoop-apache2.tar.gz
tar xzf presto-hadoop-apache2.tar.gz
mvn clean package -f presto-hadoop-apache2-master/pom.xml
rm presto-server-*/plugin/hive-hadoop2/hadoop-apache2-*.jar
cp presto-hadoop-apache2-master/target/hadoop-apache2-0.11-SNAPSHOT.jar presto-server-*/plugin/hive-hadoop2/

cp /usr/hdp/current/hadoop-client/hadoop-azure-*.jar  presto-server-*/plugin/hive-hadoop2/
cp /usr/hdp/current/hadoop-client/lib/jetty-util-*.hwx.jar  presto-server-*/plugin/hive-hadoop2/
cp /usr/hdp/current/hadoop-client/lib/azure-storage-*.jar presto-server-*/plugin/hive-hadoop2/

tar czf presto-server-0.163.tar.gz presto-server-*/
rm presto-yarn-package/package/files/presto-server*.tar.gz
cp presto-server-*.tar.gz presto-yarn-package/package/files/
cd presto-yarn-package
zip -r ../presto-yarn-package.zip .
cd ..
