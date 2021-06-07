#!/bin/bash
#
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
#
# Setting frontend to noninteractive to avoid password prompts
export DEBIAN_FRONTEND=noninteractive
# Installing debconf-utils for handeling interactive installations (mainly for java 8 prompts)
apt-get install -y python-software-properties debconf-utils
# Adding repository for Oracle Java 8
add-apt-repository -y ppa:webupd8team/java
# Updating the repository
apt-get -y update
# Installing Oracle Java 8 while skipping any prompts
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
apt-get -y install oracle-java8-installer
# Adding Neo4j repository
wget -O - https://debian.neo4j.org/neotechnology.gpg.key | apt-key add -
echo 'deb http://debian.neo4j.org/repo stable/' | tee -a /etc/apt/sources.list.d/neo4j.list
# Updating repository
apt-get -y  update
# Installing Neo4j. Neo4j version and edition passed as parameter
# Example: neo4j=3.3.0 or neo4j-enterprise=3.3.0
# Version can be skipped to get latest version on repository. Example: neo4j
apt-get -y  install $1
# Backup for original configuration file
cp -p /etc/neo4j/neo4j.conf /etc/neo4j/neo4j.conf.bak
# Manually setting Neo4j configuration by manipulating values in neo4j.conf
# First, we allow incoming connections from outside of localhost. By default neo4j rejects connections from non-local clients
sed -i -e 's@#dbms.connectors.default_listen_address=0.0.0.0@dbms.connectors.default_listen_address=0.0.0.0@g' /etc/neo4j/neo4j.conf
# enabling Neo4j to start when the Ubuntu starts
systemctl enable neo4j
#manually starting Neo4j for the first time
systemctl restart neo4j
