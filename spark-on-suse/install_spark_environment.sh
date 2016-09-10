#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2015 Microsoft Azure
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# Author: Value Amplify Group

install_prerequisites()
{
	echo "Updating Suse"
	sudo zypper update -y
	sudo zypper install -y install git
	
	echo "Installing Java"
	sudo zypper install update-alternatives
	sudo ln -s /usr/sbin/update-alternatives /usr/sbin/alternatives
	
	curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.rpm > /home/sparkuser/jdk-8u102-linux-x64.rpm
	
	sudo rpm -ivh /home/sparkuser/jdk-8u102-linux-x64.rpm
	
	echo "Installing Java"
	wget -O /home/sparkuser/hadoop-2.7.3.tar.gz http://apache.panu.it/hadoop/core/hadoop-2.7.3/hadoop-2.7.3.tar.gz 
	
	tar -zxf /home/sparkuser/hadoop-2.7.3.tar.gz	
	
}

install_apache_spark()
{
	cd ~
	mkdir /usr/local/spark
	cd /usr/local/spark/
	
	echo "Downloading and unpacking Spark"
	wget http://apache.panu.it/spark/spark-2.0.0/spark-2.0.0-bin-hadoop2.7.tgz
	
	tar xvzf spark-*.tgz > /tmp/spark-on-suse.log
	rm spark-*.tgz
	mv spark-2.0.0-bin-hadoop2.7 ../
	cd ..
	cd /usr/local/
	sudo ln -s spark-2.0.0-bin-hadoop2.7 spark

	
}

echo "Executing Custom Script"


# install_prerequisites()


#install_apache_spark()



