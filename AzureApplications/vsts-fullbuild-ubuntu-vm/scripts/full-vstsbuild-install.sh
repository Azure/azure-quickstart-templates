#!/bin/sh

# Install Build Tools
sudo /bin/date +%H:%M:%S > /home/$5/install.progress.txt

echo "ooooo      FULL INSTALL      ooooo" >> /home/$5/install.progress.txt

echo "Installing build-essential package" >> /home/$5/install.progress.txt
sudo apt-get -y install build-essential
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt

echo "Installing packaging-dev package" >> /home/$5/install.progress.txt
sudo apt-get -y install packaging-dev
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt


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
echo "Installing ant package" >> /home/$5/install.progress.txt
sudo apt-get -y install ant
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt

echo "Installing maven package" >> /home/$5/install.progress.txt
sudo apt-get -y install maven
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt

echo "Installing gradle package" >> /home/$5/install.progress.txt
sudo apt-get -y install gradle
sudo -u $5 /usr/bin/gradle
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt

# Install NodeJS, npm, and gulp

echo "Installing NodeJS package" >> /home/$5/install.progress.txt
sudo curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt

echo "Installing gulp package" >> /home/$5/install.progress.txt
sudo npm install -g gulp
sudo -u $5 npm install gulp --save-dev
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt


# Install Ruby and Ruby on Rails
echo "Installing Ruby and Ruby on Rails" >> /home/$5/install.progress.txt
sudo -u $5 gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
sudo -u $5 \curl -sSL https://get.rvm.io | sudo -u $5 bash -s stable --rails
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt


# Install Go
echo "Installing Go" >> /home/$5/install.progress.txt
sudo apt install -y golang-go
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt

sudo -u $5 mkdir /home/$5/downloads
sudo -u $5 mkdir /home/$5/lib

# Install latest release of .NET Core
echo "Installing .NET" >> /home/$5/install.progress.txt
sudo -u $5 mkdir /home/$5/lib/dotnet
cd /home/$5/downloads
sudo -u $5 wget https://dotnetcli.blob.core.windows.net/dotnet/preview/Binaries/Latest/dotnet-ubuntu.16.04-x64.latest.tar.gz
cd /home/$5/lib/dotnet
sudo -u $5 tar zxfv /home/$5/downloads/dotnet-ubuntu.16.04-x64.latest.tar.gz
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt

# Install Docker Engine and Compose
echo "Installing Docker Engine and Compose" >> /home/$5/install.progress.txt
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get install -y docker-engine
sudo service docker start
sudo systemctl enable docker
sudo groupadd docker
sudo usermod -aG docker $5

sudo curl -L https://github.com/docker/compose/releases/download/1.9.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt

# Install VSTS build agent dependencies

echo "Installing libunwind8 and libcurl3 package" >> /home/$5/install.progress.txt
sudo apt-get -y install libunwind8 libcurl3
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt


# Download VSTS build agent and required security patch

echo "Downloading VSTS Build agent package" >> /home/$5/install.progress.txt

cd /home/$5/downloads

sudo -u $5 wget https://github.com/Microsoft/vsts-agent/releases/download/v2.109.2/vsts-agent-ubuntu.14.04-x64-2.109.2.tar.gz
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

# HACK - only needed if .NET and Ruby/Rails are installed
sudo -u $5 echo $PATH:/home/$5/lib/dotnet:/home/$5/.rvm/bin > /home/$5/vsts-agent/.path

# HACK - Remove NODE_ENV=production from service template file
sudo sed -i 's,NODE_ENV=production,,g' ./bin/vsts.agent.service.template

echo URL: $1 > /home/$5/vsts.install.log.txt 2>&1
echo PAT: HIDDEN >> /home/$5/vsts.install.log.txt 2>&1
echo Pool: $3 >> /home/$5/vsts.install.log.txt 2>&1
echo Agent: $4 >> /home/$5/vsts.install.log.txt 2>&1
echo User: $5 >> /home/$5/vsts.install.log.txt 2>&1
echo =============================== >> /home/$5/vsts.install.log.txt 2>&1

echo Running Agent.Listener >> /home/$5/vsts.install.log.txt 2>&1
sudo -u $5 -E bin/Agent.Listener configure --unattended --nostart --replace --acceptteeeula --url $1 --auth PAT --token $2 --pool $3 --agent $4 >> /home/$5/vsts.install.log.txt 2>&1
echo =============================== >> /home/$5/vsts.install.log.txt 2>&1
echo Running ./svc.sh install >> /home/$5/vsts.install.log.txt 2>&1
sudo -E ./svc.sh install $5 >> /home/$5/vsts.install.log.txt 2>&1
echo =============================== >> /home/$5/vsts.install.log.txt 2>&1
echo Running ./svc.sh start >> /home/$5/vsts.install.log.txt 2>&1

# HACK - only need next 3 lines if installing Ruby and Rails
sudo sed -i "/^#!\/bin\/bash/a [[ -s \"\/home\/$5\/.rvm\/scripts\/rvm\" ]] \&\& source \"\/home\/$5\/.rvm\/scripts\/rvm\" \#L1P1" ./runsvc.sh
sudo sed -i "/L1P1/a echo \`cat .path\`:\$MY_RUBY_HOME/bin:\$GEM_HOME/bin > .mypath \#L2P2" ./runsvc.sh
sudo sed -i "/L2P2/a cp .mypath .path" ./runsvc.sh

sudo -E ./svc.sh start >> /home/$5/vsts.install.log.txt 2>&1
echo =============================== >> /home/$5/vsts.install.log.txt 2>&1

sudo chown -R $5.$5 .*

echo "ALL DONE!" >> /home/$5/install.progress.txt
sudo /bin/date +%H:%M:%S >> /home/$5/install.progress.txt