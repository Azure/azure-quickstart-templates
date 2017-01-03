#!/bin/sh

/bin/date +%H:%M:%S > /home/$5/install.progress.txt
echo "ooooo      REDHAT VSTS BUILD INSTALL      ooooo" >> /home/$5/install.progress.txt

echo "Initial basic development packages" >> /home/$5/install.progress.txt
yum install -y gcc > /home/$5/install.out.txt 2>&1
yum install -y gcc-c++ >> /home/$5/install.out.txt 2>&1
yum install -y httpd-devel >> /home/$5/install.out.txt 2>&1
yum install -y patch readline readline-devel zlib zlib-devel >> /home/$5/install.out.txt 2>&1
yum install -y libyaml-devel libffi-devel openssl-devel make >> /home/$5/install.out.txt 2>&1
yum install -y bzip2 autoconf automake libtool bison iconv-devel >> /home/$5/install.out.txt 2>&1
/bin/date +%H:%M:%S >> /home/$5/install.progress.txt

echo "Install X11 Packages" >> /home/$5/install.progress.txt
yum install -y xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-apps
/bin/date +%H:%M:%S >> /home/$5/install.progress.txt

echo "Install OpenJDK Java packages" >> /home/$5/install.progress.txt
yum install -y java-1.6.0-openjdk-devel >> /home/$5/install.out.txt 2>&1
yum install -y java-1.7.0-openjdk-devel >> /home/$5/install.out.txt 2>&1
yum install -y java-1.8.0-openjdk-devel >> /home/$5/install.out.txt 2>&1
/bin/date +%H:%M:%S >> /home/$5/install.progress.txt

echo "Install Default Ant and Maven" >> /home/$5/install.progress.txt
yum install -y ant >> /home/$5/install.out.txt 2>&1
yum install -y maven >> /home/$5/install.out.txt 2>&1
/bin/date +%H:%M:%S >> /home/$5/install.progress.txt

echo "Install Gradle 3.0" >> /home/$5/install.progress.txt
mkdir /home/$5/downloads
cd /home/$5/downloads
wget http://services.gradle.org/distributions/gradle-3.0-all.zip >> /home/$5/install.out.txt 2>&1
unzip gradle-3.0-all.zip -d /opt/gradle >> /home/$5/install.out.txt 2>&1
ln -s /opt/gradle/gradle-3.0/bin/gradle /usr/local/bin
/bin/date +%H:%M:%S >> /home/$5/install.progress.txt

echo "NodeJS, npm and gulp" >> /home/$5/install.progress.txt
curl -sL https://rpm.nodesource.com/setup_6.x | bash - >> /home/$5/install.out.txt 2>&1
yum install -y nodejs >> /home/$5/install.out.txt 2>&1
npm install gulp -g >> /home/$5/install.out.txt 2>&1
npm install gulp --save-dev >> /home/$5/install.out.txt 2>&1
/bin/date +%H:%M:%S >> /home/$5/install.progress.txt

echo "Groovy" >> /home/$5/install.progress.txt
yum install -y groovy >> /home/$5/install.out.txt 2>&1
/bin/date +%H:%M:%S >> /home/$5/install.progress.txt

echo "Install Ruby, Gems and Rails" >> /home/$5/install.progress.txt
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 >> /home/$5/install.out.txt 2>&1
curl -L get.rvm.io | bash -s stable >> /home/$5/install.out.txt 2>&1
# source /etc/profile.d/rvm.sh
/usr/local/rvm/bin/rvm install 2.3.0 >> /home/$5/install.out.txt 2>&1
/usr/local/rvm/bin/rvm all do gem install rails >> /home/$5/install.out.txt 2>&1
/usr/local/rvm/bin/rvm all do gem install executable-hooks >> /home/$5/install.out.txt 2>&1
/bin/date +%H:%M:%S >> /home/$5/install.progress.txt

echo "Go Language" >> /home/$5/install.progress.txt
yum install -y golang >> /home/$5/install.out.txt 2>&1
/bin/date +%H:%M:%S >> /home/$5/install.progress.txt

# Install VSTS build agent dependencies
cd /home/$5

echo "Installing libunwind8 package" >> /home/$5/install.progress.txt
yum -y install libunwind.x86_64 icu >> /home/$5/install.out.txt 2>&1
/bin/date +%H:%M:%S >> /home/$5/install.progress.txt


yum install -y curl-devel expat-devel gettext-devel openssl-devel zlib-devel >> /home/$5/install.out.txt 2>&1
yum install -y gcc perl-ExtUtils-MakeMaker >> /home/$5/install.out.txt 2>&1

echo "Installing and building git 2.9.2" >> /home/$5/install.progress.txt

cd /usr/src
wget https://www.kernel.org/pub/software/scm/git/git-2.9.2.tar.gz >> /home/$5/install.out.txt 2>&1
tar xzf git-2.9.2.tar.gz >> /home/$5/install.out.txt 2>&1

cd git-2.9.2
make prefix=/usr/local/git all >> /home/$5/install.out.txt 2>&1
make prefix=/usr/local/git install >> /home/$5/install.out.txt 2>&1
mv /usr/bin/git /usr/bin/git_Orig
ln -s /usr/local/git/bin/git /usr/bin/git

/bin/date +%H:%M:%S >> /home/$5/install.progress.txt

# Install Docker Engine and Docker Compose
echo "Installing Docker Engine and Docker Compose" >> /home/$5/install.progress.txt
yum update -y --exclude=WALinuxAgent >> /home/$5/install.out.txt 2>&1
# yum update -y >> /home/$5/install.out.txt 2>&1

echo [dockerrepo] > /etc/yum.repos.d/docker.repo
echo name=Docker Repository >> /etc/yum.repos.d/docker.repo
echo baseurl=https://yum.dockerproject.org/repo/main/centos/7/ >> /etc/yum.repos.d/docker.repo
echo enabled=1 >> /etc/yum.repos.d/docker.repo
echo gpgcheck=1 >> /etc/yum.repos.d/docker.repo
echo gpgkey=https://yum.dockerproject.org/gpg >> /etc/yum.repos.d/docker.repo

yum install -y docker-engine >> /home/$5/install.out.txt 2>&1
systemctl enable docker.service
systemctl start docker
systemctl enable docker
groupadd docker
usermod -aG docker $5

curl -L https://github.com/docker/compose/releases/download/1.9.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose >> /home/$5/install.out.txt 2>&1

/bin/date +%H:%M:%S >> /home/$5/install.progress.txt


# Install latest .NET Core
echo "Installing latest .NET Core" >> /home/$5/install.progress.txt
# mkdir /home/$5/lib
# mkdir /home/$5/lib/dotnet
# cd /home/$5/downloads
# wget https://dotnetcli.blob.core.windows.net/dotnet/preview/Binaries/1.0.0-preview2-003131/dotnet-dev-rhel-x64.1.0.0-preview2-003131.tar.gz >> /home/$5/install.out.txt 2>&1
# cd /home/$5/lib/dotnet
# tar zxfv /home/$5/downloads/dotnet-dev-rhel-x64.1.0.0-preview2-003131.tar.gz >> /home/$5/install.out.txt 2>&1
# yum install -y scl-utils >> /home/$5/install.out.txt 2>&1
# yum install -y rh-dotnetcore11 >> /home/$5/install.out.txt 2>&1
# scl enable rh-dotnetcore11 bash
cd /home/$5/downloads
curl -sSL -o dotnet.tar.gz https://go.microsoft.com/fwlink/?LinkID=834983 >> /home/$5/install.out.txt 2>&1
mkdir -p /opt/dotnet
tar zxf dotnet.tar.gz -C /opt/dotnet >> /home/$5/install.out.txt 2>&1
ln -s /opt/dotnet/dotnet /usr/local/bin

/bin/date +%H:%M:%S >> /home/$5/install.progress.txt


# Download VSTS build agent and required security patch

echo "Downloading VSTS Build agent package" >> /home/$5/install.progress.txt

cd /home/$5/downloads

wget https://github.com/Microsoft/vsts-agent/releases/download/v2.109.2/vsts-agent-rhel.7.2-x64-2.109.2.tar.gz >> /home/$5/install.out.txt 2>&1

/bin/date +%H:%M:%S >> /home/$5/install.progress.txt


echo "Installing VSTS Build agent package" >> /home/$5/install.progress.txt

# Install VSTS agent
mkdir /home/$5/vsts-agent
cd /home/$5/vsts-agent
tar xzf /home/$5/downloads/vsts-agent-rhel.7.2* >> /home/$5/install.out.txt 2>&1

echo "LANG=en_US.UTF-8" > .env
echo "export LANG=en_US.UTF-8" >> /home/$5/.bashrc
export LANG=en_US.UTF-8
echo "JAVA_HOME=/usr/lib/jvm/java-1.8.0" >> .env
echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0" >> /home/$5/.bashrc
export JAVA_HOME=/usr/lib/jvm/java-1.8.0

export JAVA_HOME_6_X64=/usr/lib/jvm/java-1.6.0
echo "JAVA_HOME_6_X64=/usr/lib/jvm/java-1.6.0" >> .env
echo "export JAVA_HOME_6_X64=/usr/lib/jvm/java-1.6.0" >> /home/$5/.bashrc
export JAVA_HOME_7_X64=/usr/lib/jvm/java-1.7.0
echo "JAVA_HOME_7_X64=/usr/lib/jvm/java-1.7.0" >> .env
echo "export JAVA_HOME_7_X64=/usr/lib/jvm/java-1.7.0" >> /home/$5/.bashrc
echo "JAVA_HOME_8_X64=/usr/lib/jvm/java-1.8.0" >> .env
echo "export JAVA_HOME_8_X64=/usr/lib/jvm/java-1.8.0" >> /home/$5/.bashrc
export JAVA_HOME_8_X64=/usr/lib/jvm/java-1.8.0

echo $PATH:/usr/local/bin:/home/$5/lib/dotnet:/usr/local/rvm/bin:/usr/local/rvm/gems/ruby-2.3.0/wrappers:/usr/local/rvm/gems/ruby-2.3.0/bin/ > /home/$5/vsts-agent/.path

echo URL: $1 > /home/$5/vsts.install.log.txt 2>&1
echo PAT: HIDDEN >> /home/$5/vsts.install.log.txt 2>&1
echo Pool: $3 >> /home/$5/vsts.install.log.txt 2>&1
echo Agent: $4 >> /home/$5/vsts.install.log.txt 2>&1
echo User: $5 >> /home/$5/vsts.install.log.txt 2>&1
echo =============================== >> /home/$5/vsts.install.log.txt 2>&1

sed -i 's,Defaults    requiretty,#Defaults    requiretty,g' /etc/sudoers

echo Running Agent.Listener >> /home/$5/vsts.install.log.txt 2>&1
sudo -u $5 -E bin/Agent.Listener configure --unattended --nostart --replace --acceptteeeula --url $1 --auth PAT --token $2 --pool $3 --agent $4 >> /home/$5/vsts.install.log.txt 2>&1
echo =============================== >> /home/$5/vsts.install.log.txt 2>&1
echo Running ./svc.sh install >> /home/$5/vsts.install.log.txt 2>&1
sudo -E ./svc.sh install $5 >> /home/$5/vsts.install.log.txt 2>&1
echo =============================== >> /home/$5/vsts.install.log.txt 2>&1
echo Running ./svc.sh start >> /home/$5/vsts.install.log.txt 2>&1

sudo -E ./svc.sh start >> /home/$5/vsts.install.log.txt 2>&1
echo =============================== >> /home/$5/vsts.install.log.txt 2>&1

sed -i 's,#Defaults    requiretty,Defaults    requiretty,g' /etc/sudoers

cd /home/$5
chown -R $5.$5 .*
# cd /home/$5/downloads
# chown -R $5.$5 .*
# cd /home/$5/lib
# chown -R $5.$5 .*
# cd /home/$5/lib/dotnet
# chown -R $5.$5 .*
# cd /home/$5/vsts-agent
# chown -R $5.$5 .*

echo "ALL DONE!" >> /home/$5/install.progress.txt
/bin/date +%H:%M:%S >> /home/$5/install.progress.txt
