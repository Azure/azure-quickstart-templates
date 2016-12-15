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

echo "export PATH=$PATH:/usr/hdp/current/spark/bin" | sudo tee -a /etc/profile
echo "export PATH=$PATH:/usr/hdp/current/spark/bin" | sudo tee -a /root/.profile

# Download Spark binary to temporary location.
download_file http://d3kbcqa49mib13.cloudfront.net/spark-1.4.1-bin-hadoop2.6.tgz /tmp/spark-1.4.1-bin-hadoop2.6.tgz

# Untar the Spark binary and move it to proper location.
untar_file /tmp/spark-1.4.1-bin-hadoop2.6.tgz /usr/hdp/current
mv /usr/hdp/current/spark-1.4.1-bin-hadoop2.6 /usr/hdp/current/spark

# Remove the temporary file downloaded.
rm -f /tmp/spark-1.4.1-bin-hadoop2.6.tgz

# Update/link files/variables necessary to make Spark work on HDInsight.

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


