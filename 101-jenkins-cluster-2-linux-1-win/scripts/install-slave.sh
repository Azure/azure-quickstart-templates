apt update -y
## Install JDK8, Git & Maven
apt install openjdk-8-jdk git maven openssl -y
## Install Docker-CE
apt install docker.io -y
## allow current user to access docker daemon
usermod -aG docker $USER
## install solar-scanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.2.0.1873-linux.zip
unzip sonar-scanner-cli-4.2.0.1873-linux.zip
mv sonar-scanner-4.2.0.1873-linux/ sonar/
rm sonar-scanner-cli-4.2.0.1873-linux.zip
## create new jenkins user with password pass@12345
sudo useradd -p $(openssl passwd -1 "pass@12345") jenkins