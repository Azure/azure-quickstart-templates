Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

## Install JDK8. Maven & Git
choco install -y jdk8 maven git
choco install microsoft-build-tools -y

## Install SonarQube Scanner for Windows
wget -outFile sonar.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.2.0.1873-windows.zip
Expand-Archive -Path sonar.zip -DestinationPath .
Ren -path sonar-scanner-cli-4.2.0.1873-windows -NewName sonar
del sonar.zip