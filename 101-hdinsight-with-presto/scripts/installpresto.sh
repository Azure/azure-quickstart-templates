#!/bin/bash

wget -O /tmp/HDInsightUtilities-v01.sh -q https://hdiconfigactions.blob.core.windows.net/linuxconfigactionmodulev01/HDInsightUtilities-v01.sh && source /tmp/HDInsightUtilities-v01.sh && rm -f /tmp/HDInsightUtilities-v01.sh

mkdir /var/lib/presto
chmod -R 777 /var/lib/presto/

if [[ `hostname -f` == `get_primary_headnode` ]]; then
  apt-get update
  which mvn &> /dev/null || apt-get -y -qq install maven
  cd /var/lib/presto
  wget https://github.com/hdinsight/presto-hdinsight/archive/master.tar.gz -O presto-hdinsight.tar.gz
  tar xzf presto-hdinsight.tar.gz
  cd presto-hdinsight-master
  ./createsliderbuild.sh
  slider package --delete --name presto1
  slider package --install --name presto1 --package build/presto-yarn-package.zip
  ./createconfigs.sh
  slider stop presto1 --force
  slider destroy presto1 --force
  slider create presto1 --template appConfig-default.json --resources resources-default.json
fi

if [[ `hostname -f` == `get_primary_headnode` || `hostname -f` == `get_secondary_headnode` ]]; then
  wget https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/0.163/presto-cli-0.163-executable.jar -O /usr/local/bin/presto-cli
  chmod +x /usr/local/bin/presto-cli

  until slider registry  --name presto1 --getexp presto ; do
    echo "waiting for presto to start.."
    sleep 10
  done

  cat > /usr/local/bin/presto <<EOF
#!/bin/bash
presto-cli --server $(slider registry  --name presto1 --getexp presto |  grep value | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*:[0-9]*") --catalog hive "\$@"
EOF
  
  chmod +x /usr/local/bin/presto
fi
