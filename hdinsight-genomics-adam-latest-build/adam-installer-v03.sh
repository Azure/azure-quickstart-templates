# Import the helper method module.
wget -O /tmp/HDInsightUtilities-v01.sh -q https://hdiconfigactions.blob.core.windows.net/linuxconfigactionmodulev01/HDInsightUtilities-v01.sh && source /tmp/HDInsightUtilities-v01.sh && rm -f /tmp/HDInsightUtilities-v01.sh

# Check if the current  host is headnode.
if [ `test_is_headnode` == 0 ]; then
  echo  "Spark on YARN only need to be installed on headnode, exiting ..."
  exit 0
fi

# In case Spark is installed, exit.
if [ -e /usr/hdp/current/spark ]; then
    echo "Spark is already installed, exiting ..."
    exit 0
fi

# Add HADOOP environment variable into machine level configuration.
echo "HADOOP_CONF_DIR=/etc/hadoop/conf" | sudo tee -a /etc/environment
echo "YARN_CONF_DIR=/etc/hadoop/conf" | sudo tee -a /etc/environment

# Add SPARK_HOME environment variable for supporting application requirments (ADAM)
echo "SPARK_HOME=/usr/hdp/current/spark" | sudo tee -a /etc/environment

# Add SPARK bin directory to PATH variable

#echo "export PATH=$PATH:/usr/hdp/current/spark/bin" | sudo tee -a /etc/profile
#echo "export PATH=$PATH:/usr/hdp/current/spark/bin" | sudo tee -a /root/.profile

# Download Spark binary to temporary location.
download_file http://d3kbcqa49mib13.cloudfront.net/spark-1.4.1-bin-hadoop2.6.tgz /tmp/spark-1.4.1-bin-hadoop2.6.tgz

# Untar the Spark binary and move it to proper location.
untar_file /tmp/spark-1.4.1-bin-hadoop2.6.tgz /usr/hdp/current
mv /usr/hdp/current/spark-1.4.1-bin-hadoop2.6 /usr/hdp/current/spark

# Remove the temporary file downloaded.
rm -f /tmp/spark-1.4.1-bin-hadoop2.6.tgz

# Update variables/files to make Spark work on HDInsight.
echo "SPARK_DIST_CLASSPATH=$(hadoop classpath)" | sudo tee -a /etc/environment
ln -s /etc/hive/conf/hive-site.xml /usr/hdp/current/spark/conf


#Determine Hortonworks Data Platform version
HDP_VERSION=`ls /usr/hdp/ -I current`

#Assign java options to support Spark
SparkDriverJavaOpts="spark.driver.extraJavaOptions -Dhdp.version=$HDP_VERSION"
SparkYarnJavaOpts="spark.yarn.am.extraJavaOptions -Dhdp.version=$HDP_VERSION"

#Create file and update with default values
SparkDefaults="/tmp/spark-defaults.conf"
echo $SparkDriverJavaOpts >> $SparkDefaults
echo $SparkYarnJavaOpts >> $SparkDefaults
touch $SparkDefaults

#Move to final destination
mv $SparkDefaults /usr/hdp/current/spark/conf/spark-defaults.conf


#Install Maven in preperation for ADAM

download_file http://mirror.olnevhost.net/pub/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz /tmp/apache-maven-3.3.3-bin.tar.gz
untar_file /tmp/apache-maven-3.3.3-bin.tar.gz /tmp
mv /tmp/apache-maven-3.3.3 /maven

#Install Git and GeneTorrent Download common packages in preperation for ADAM
apt-get install -y git libboost-filesystem1.48.0 libboost-program-options1.48.0 libboost-regex1.48.0 libboost-system1.48.0 libicu48 libxerces-c3.1 libxqilla6
download_file https://cghub.ucsc.edu/software/downloads/GeneTorrent/3.8.7/GeneTorrent-download-3.8.7-207-Ubuntu12.04.x86_64.tar.gz /tmp/GeneTorrent-download-3.8.7-207-Ubuntu12.04.x86_64.tar.gz
untar_file /tmp/GeneTorrent-download-3.8.7-207-Ubuntu12.04.x86_64.tar.gz /tmp
mv /tmp/cghub /cghub

#Install ADAM
#echo "export PATH=$PATH:/usr/hdp/current/spark/bin:/maven/bin:/adam/bin"
cd /
git clone https://github.com/bigdatagenomics/adam.git
cd adam
export "MAVEN_OPTS=-Xmx512m -XX:MaxPermSize=128m"
/maven/bin/mvn clean package -DskipTests

#Update Environment Variables
echo "export PATH=$PATH:/usr/hdp/current/spark/bin:/maven/bin:/adam/bin:/cghub/bin" | sudo tee -a /etc/profile
echo "export PATH=$PATH:/usr/hdp/current/spark/bin:/maven/bin:/adam/bin:/cghub/bin" | sudo tee -a /root/.profile
echo "ADAM_HOME=/adam" | sudo tee -a /etc/environment

