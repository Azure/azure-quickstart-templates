#!/bin/bash

echo "Install SafeKit from `ls ./*.bin`"


chmod +x ./safekit*.bin
./safekit*.bin


yum -y localinstall ./safekit*.rpm
#rm ./safekit*.bin ./safekit*.rpm

echo "Install powershell"
# Register the Microsoft RedHat repository
curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
yum update powershell
# Install PowerShell
yum install -y powershell
if [ -f "installAzureRM.ps1" ]; then
	pwsh ./installAzureRM.ps1 -linux
fi
echo "starting CA helper service"
cd /opt/safekit/web/bin
./startcaserv "$2"
