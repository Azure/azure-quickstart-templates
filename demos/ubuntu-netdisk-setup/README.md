# Deployment of Net Disk against Ubuntu 

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ubuntu-netdisk-setup/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ubuntu-netdisk-setup/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ubuntu-netdisk-setup/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ubuntu-netdisk-setup/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ubuntu-netdisk-setup/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ubuntu-netdisk-setup/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fubuntu-netdisk-setup%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fubuntu-netdisk-setup%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fubuntu-netdisk-setup%2Fazuredeploy.json)

This template allows deploying seafile server 6.1.1 on Azure Ubuntu VM. It can be used as a personal or private enterprise net disk. seafile is an open-source software to build your own cloud storage. It provides rich client/server features to meet your daily requirement. On server side, it supports data deduplication, file block upload/download, and encryption. For client, it supports iOS, Android, windows, Linux, and Mac. For more details, please refer to www.seafile.com. This deployment gives you 1T data disk as seafile data storage. The data was saved on ZFS file system, so, it can be easily extended by adding more data disks if your data storage is full. Furthermore, you can easily backup all your data and transfer it to another VM if you want.



