# Param(
#     [string]$minHeapSize,
#     [string]$maxHeapSize
# )

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install jdk8 -y
choco install maven --version 3.5.4 -y
choco install python3 --version 3.7.0 -y

$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
refreshenv

New-Item -ItemType directory -Force -Path C:\Temp\hazelcast

python -V
python .\modify_configuration.py --cluster-name=$clusterName --subscription-id=$subscriptionId --aad-client-id=$aadClientId --aad-client-secret=$aadClientSecret --tenant-id=$aadTenantId --group-name=$groupName --cluster-tag=$clusterTag --cluster-port=$clusterPort --filename=.\hazelcast.xml
python .\modify_version.py --hazelcast-version=$hazelcastVersion --filename=.\pom.xml

Copy-Item .\hazelcast.xml -Destination C:\Temp\hazelcast
Copy-Item .\pom.xml -Destination C:\Temp\hazelcast