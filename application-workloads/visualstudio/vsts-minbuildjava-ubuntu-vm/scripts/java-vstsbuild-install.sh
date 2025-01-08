#!/bin/sh

# Install Build Tools
sudo /bin/date +%H:%M:%S > /home/$5/install.progress.txt

echo "ooooo      MINIMUM INSTALL      ooooo" >> /home/$5/install.progress.txt

# Install Java

# echo "Installing Oracle Java 6 package" >> /home/$5/install.progress.txt

# Install Oracle Java in silent mode
# echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
# echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

# sudo add-apt-repository -y ppa:webupd8team/java
# sudo apt-get -y update
# sudo apt-get install -y oracle-java6-installer

# sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt

# echo "Installing Oracle Java 7 package" >> /home/$5/install.progress.txt

# sudo apt-get install -y oracle-java7-installer

# sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt

# echo "Installing Oracle Java 8 package" >> /home/$5/install.progress.txt

# sudo apt-get install -y oracle-java8-installer

# sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt

echo "Installing openjdk-7-jdk package" >> /home/$5/install.progress.txt

sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get -y update
sudo apt-get install -y openjdk-7-jdk
sudo apt-get -y update --fix-missing
sudo apt-get install -y openjdk-7-jdk
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt

echo "Installing openjdk-8-jdk package" >> /home/$5/install.progress.txt

sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get -y update
sudo apt-get install -y openjdk-8-jdk
sudo apt-get -y update --fix-missing
sudo apt-get install -y openjdk-8-jdk

sudo ln -s /usr/lib/jvm/java-8-openjdk-amd64/ /usr/lib/jvm/default-java

sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt


# Install Java build tools

echo "Installing maven package" >> /home/$5/install.progress.txt
sudo apt-get -y install maven
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt



sudo -u $5 mkdir /home/$5/downloads
sudo -u $5 mkdir /home/$5/lib

# Install VSTS build agent dependencies

echo "Installing libunwind8 and libcurl3 package" >> /home/$5/install.progress.txt
sudo apt-get -y install libunwind8 libcurl3
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt


# Download VSTS build agent and required security patch

echo "Downloading VSTS Build agent package" >> /home/$5/install.progress.txt

cd /home/$5/downloads

# sudo -u $5 wget https://github.com/Microsoft/vsts-agent/releases/download/v2.101.1/vsts-agent-ubuntu.14.04-x64-2.101.1.tar.gz
# sudo -u $5 wget https://github.com/Microsoft/vsts-agent/releases/download/v2.102.1/vsts-agent-ubuntu.14.04-x64-2.102.1.tar.gz
sudo -u $5 wget https://github.com/Microsoft/vsts-agent/releases/download/v2.104.2/vsts-agent-ubuntu.14.04-x64-2.104.2.tar.gz
sudo -u $5 wget http://security.ubuntu.com/ubuntu/pool/main/i/icu/libicu52_52.1-8ubuntu0.2_amd64.deb
sudo dpkg -i libicu52_52.1-8ubuntu0.2_amd64.deb

sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt


echo "Installing VSTS Build agent package" >> /home/$5/install.progress.txt

# Install VSTS agent
sudo -u $5 mkdir /home/$5/vsts-agent
cd /home/$5/vsts-agent
sudo -u $5 tar xzf /home/$5/downloads/vsts-agent-ubuntu*

echo "LANG=en_US.UTF-8" > .env
echo "export LANG=en_US.UTF-8" >> /home/$5/.bashrc
export LANG=en_US.UTF-8
echo "JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> .env
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /home/$5/.bashrc
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
# export JAVA_HOME_6_X64=/usr/lib/jvm/java-6-oracle
# echo "JAVA_HOME_6_X64=/usr/lib/jvm/java-6-oracle" >> .env
# echo "export JAVA_HOME_6_X64=/usr/lib/jvm/java-6-oracle" >> /home/$5/.bashrc
# export JAVA_HOME_6_X64=/usr/lib/jvm/java-6-oracle
# export JAVA_HOME_7_X64=/usr/lib/jvm/java-7-oracle
# echo "JAVA_HOME_7_X64=/usr/lib/jvm/java-7-oracle" >> .env
# echo "export JAVA_HOME_7_X64=/usr/lib/jvm/java-7-oracle" >> /home/$5/.bashrc
export JAVA_HOME_7_X64=/usr/lib/jvm/java-7-openjdk-amd64
echo "JAVA_HOME_7_X64=/usr/lib/jvm/java-7-openjdk-amd64" >> .env
echo "export JAVA_HOME_7_X64=/usr/lib/jvm/java-7-openjdk-amd64" >> /home/$5/.bashrc
echo "JAVA_HOME_8_X64=/usr/lib/jvm/java-8-openjdk-amd64" >> .env
echo "export JAVA_HOME_8_X64=/usr/lib/jvm/java-8-openjdk-amd64" >> /home/$5/.bashrc
export JAVA_HOME_8_X64=/usr/lib/jvm/java-8-openjdk-amd64

echo URL: $1 > /home/$5/vsts.install.log.txt 2>&1
echo PAT: HIDDEN >> /home/$5/vsts.install.log.txt 2>&1
echo Pool: $3 >> /home/$5/vsts.install.log.txt 2>&1
echo Agent: $4 >> /home/$5/vsts.install.log.txt 2>&1
echo User: $5 >> /home/$5/vsts.install.log.txt 2>&1
echo =============================== >> /home/$5/vsts.install.log.txt 2>&1
echo Running Agent.Listener >> /home/$5/vsts.install.log.txt 2>&1
sudo -u $5 -E bin/Agent.Listener --configure --unattended --nostart --replace --acceptteeeula --url $1 --auth PAT --token $2 --pool $3 --agent $4 >> /home/$5/vsts.install.log.txt 2>&1
echo =============================== >> /home/$5/vsts.install.log.txt 2>&1
echo Running ./svc.sh install >> /home/$5/vsts.install.log.txt 2>&1
sudo -E ./svc.sh install $5 >> /home/$5/vsts.install.log.txt 2>&1
echo =============================== >> /home/$5/vsts.install.log.txt 2>&1
echo Running ./svc.sh start >> /home/$5/vsts.install.log.txt 2>&1

sudo -E ./svc.sh start >> /home/$5/vsts.install.log.txt 2>&1
echo =============================== >> /home/$5/vsts.install.log.txt 2>&1

sudo chown -R $5.$5 .*

echo "ALL DONE!" >> /home/$5/install.progress.txt
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt
