apt update -y
## Install JDK8, Git & Maven
apt install openjdk-8-jdk git maven  -y
## Install Docker-CE
apt install docker.io -y
## create new jenkins user
useradd -m -s /bin/bash jenkins
## Allow JENKINS user to access docker
usermod -aG docker jenkins
## Create TOOLS directory for jenkins
mkdir /opt/tools/
cd /opt/tools
## install solar-scanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.2.0.1873-linux.zip
jar -xvf sonar-scanner-cli-4.2.0.1873-linux.zip
mv sonar-scanner-4.2.0.1873-linux/ sonar/
rm sonar-scanner-cli-4.2.0.1873-linux.zip
## Change OWNER of tools to "jenkins"
chown -R jenkins:jenkins /opt/tools/