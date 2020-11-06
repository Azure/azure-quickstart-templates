#!/bin/bash

# Instructions mostly from https://www.edureka.co/blog/install-hadoop-single-node-hadoop-cluster

## Install prereqs
# Update system
sudo zypper update
# Install Java
sudo zypper install -y java-1_8_0-openjdk

# Download Hadoop binary and extract to $HOME
wget -c https://downloads.apache.org/hadoop/core/hadoop-3.1.4/hadoop-3.1.4.tar.gz -O - | tar -xz -C $HOME

# Add the Hadoop and Java paths in the bash file (.bashrc)
cat >>$HOME/.bashrc <<EOL
## Added by Quickstart to support Hadoop
export HADOOP_HOME=$HOME/hadoop-3.1.4
export HADOOP_CONF_DIR=$HOME/hadoop-3.1.4/etc/hadoop
export HADOOP_MAPRED_HOME=$HOME/hadoop-3.1.4
export HADOOP_COMMON_HOME=$HOME/hadoop-3.1.4
export HADOOP_HDFS_HOME=$HOME/hadoop-3.1.4
export YARN_HOME=$HOME/hadoop-3.1.4
export HDFS_NAMENODE_USER="AzureUser"
export HDFS_DATANODE_USER="AzureUser"
export HDFS_SECONDARYNAMENODE_USER="AzureUser"
export YARN_RESOURCEMANAGER_USER="AzureUser"
export YARN_NODEMANAGER_USER="AzureUser"
export JAVA_HOME=/usr/lib64/jvm/jre-1.8.0-openjdk
export PATH=/usr/lib64/jvm/jre-1.8.0-openjdk:$PATH:$HOME/hadoop-3.1.4/bin
# End Quickstart variables
EOL

# Source .bashrc
source $HOME/.bashrc

# Open core-site.xml and edit the property mentioned below inside configuration tag
sed -i '/<configuration>/a <property>\n<name>fs.default.name</name>\n<value>hdfs://localhost:9000</value>\n</property>' $HADOOP_HOME/etc/hadoop/core-site.xml

# Open hdfs-site.xml and edit the property mentioned below inside configuration tag
sed -i '/<configuration>/a <property>\n<name>dfs.replication</name>\n<value>1</value>\n</property>\n<property>\n<name>dfs.permission</name>\n<value>false</value>\n</property>' $HADOOP_HOME/etc/hadoop/hdfs-site.xml

# Open the mapred-site.xml file and edit the property mentioned below inside configuration tag
sed -i '/<configuration>/a <property>\n<name>mapreduce.framework.name</name>\n<value>yarn</value>\n</property>' $HADOOP_HOME/etc/hadoop/mapred-site.xml

# Open yarn-site.xml and edit the property mentioned below inside configuration tag
sed -i '/<configuration>/a <property>\n<name>yarn.nodemanager.aux-services</name>\n<value>mapreduce_shuffle</value>\n</property>\n<property>\n<name>yarn.nodemanager.auxservices.mapreduce.shuffle.class</name>\n<value>org.apache.hadoop.mapred.ShuffleHandler</value>\n</property>' $HADOOP_HOME/etc/hadoop/yarn-site.xml

# Edit hadoop-env.sh and add the Java Path as mentioned below
sed -i 's/# export JAVA_HOME=/export JAVA_HOME=\/usr\/lib64\/jvm\/jre-1.8.0-openjdk/g' $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# This formats the HDFS via NameNode. This command is only executed for the first time. 
# Formatting the file system means initializing the directory specified by the dfs.name.dir variable.
# Never format, up and running Hadoop filesystem. You will lose all your data stored in the HDFS.  
sudo $HADOOP_HOME/bin/hdfs namenode -format
sudo chown AzureUser:users $HADOOP_HOME/logs

#Once the NameNode is formatted, start all the daemons.

# Start NameNode:
# The NameNode is the centerpiece of an HDFS file system. It keeps the directory tree of all files stored in the HDFS and tracks all the file stored across the cluster.
echo "hdfs --daemon start namenode"
hdfs --daemon start namenode

# Start DataNode:
# On startup, a DataNode connects to the Namenode and it responds to the requests from the Namenode for different operations.
echo "hdfs --daemon start datanode"
hdfs --daemon start datanode

# Start ResourceManager:
# ResourceManager is the master that arbitrates all the available cluster resources and thus helps in managing the distributed applications running on the YARN system. Its work is to manage each NodeManagers and the each application’s ApplicationMaster.
echo "yarn --daemon start resourcemanager"
yarn --daemon start resourcemanager

# Start NodeManager:
# The NodeManager in each machine framework is the agent which is responsible for managing containers, monitoring their resource usage and reporting the same to the ResourceManager.
echo "yarn --daemon start nodemanager"
yarn --daemon start nodemanager

# Start JobHistoryServer:
# JobHistoryServer is responsible for servicing all job history related requests from client.
echo "mapred --daemon start historyserver"
mapred --daemon start historyserver
