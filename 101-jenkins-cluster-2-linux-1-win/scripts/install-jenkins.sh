wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
sh -c 'echo deb http://pkg.jenkins-ci.org/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt update -y
apt install openjdk-8-jdk git maven unzip -y
apt install jenkins -y
systemctl enable jenkins
## Install solar scanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.2.0.1873-linux.zip
unzip sonar-scanner-cli-4.2.0.1873-linux.zip
mv sonar-scanner-4.2.0.1873-linux/ sonar/
rm sonar-scanner-cli-4.2.0.1873-linux.zip
### SONARQUBE SETUP
# Update kernel memory page limits and max files limits (MANDATORY FOR SONARQUBE)
sysctl -w vm.max_map_count=262144
sysctl -w fs.file-max=65536
ulimit -n 65536
ulimit -u 4096
# Download SonarQube 7.1 (Compatible with JDK 8)
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.1.zip
unzip sonarqube-7.1.zip

