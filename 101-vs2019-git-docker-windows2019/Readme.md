# Container Development with Visual Studio 2019 Community Edition

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-vs2019-git-docker-windows2019/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-vs2019-git-docker-windows2019/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-vs2019-git-docker-windows2019/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-vs2019-git-docker-windows2019/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-vs2019-git-docker-windows2019/BestPracticeResult.svg)

![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-vs2019-git-docker-windows2019/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vs2019-git-docker-windows2019%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vs2019-git-docker-windows2019%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vs2019-git-docker-windows2019%2Fazuredeploy.json)   



Build containerized applications using both docker-desktop and visual studio 2019 latest community edition. The 'docker-desktop' installation using custom script extension would take around 15 to 20 minutes.

## Applications Installed

- Visual Studio CODE 
- Visual Studio 2019 Latest Community Edition
- Git for Windows
- Docker Desktop 

Please restart the Virtual machine once deployment is completed. Once restarted, launch docker-deskop from start menu. First run of docker-desktop would deploy Virtual machine for linux containers. It might add up another 5-10 minutes.

> You might need to add current user to 'docker-user' group

```pwsh
$ Add-LocalGroupMember -Group "docker-users" -Member $Env:USERNAME
$ logoff
## Please reconnect RDP Session
```