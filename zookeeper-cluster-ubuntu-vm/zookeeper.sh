#!/bin/bash
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u75-b13/jdk-7u75-linux-x64.tar.gz"
tar -xvf jdk-7*
mkdir /usr/lib/jvm
mv ./jdk1.7* /usr/lib/jvm/jdk1.7.0
update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.7.0/bin/java" 1
update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.7.0/bin/javac" 1
update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.7.0/bin/javaws" 1
chmod a+x /usr/bin/java
chmod a+x /usr/bin/javac
chmod a+x /usr/bin/javaws

cd /usr/local

wget "http://mirrors.ukfast.co.uk/sites/ftp.apache.org/zookeeper/stable/zookeeper-3.4.8.tar.gz"
tar -xvf "zookeeper-3.4.8.tar.gz"

touch zookeeper-3.4.8/conf/zoo.cfg

echo "tickTime=2000" >> zookeeper-3.4.8/conf/zoo.cfg
echo "dataDir=/var/lib/zookeeper" >> zookeeper-3.4.8/conf/zoo.cfg
echo "clientPort=2181" >> zookeeper-3.4.8/conf/zoo.cfg
echo "initLimit=5" >> zookeeper-3.4.8/conf/zoo.cfg
echo "syncLimit=2" >> zookeeper-3.4.8/conf/zoo.cfg
 
i=1
while [ $i -le $2 ]
do
    echo "server.$i=10.0.0.$(($i+3)):2888:3888" >> zookeeper-3.4.8/conf/zoo.cfg
    i=$(($i+1))
done

mkdir -p /var/lib/zookeeper

echo $(($1+1)) >> /var/lib/zookeeper/myid

zookeeper-3.4.8/bin/zkServer.sh start
