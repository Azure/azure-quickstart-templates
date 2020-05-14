# Create a new Sharepoint Farm with 3 VMs

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/sharepoint-three-vm/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/sharepoint-three-vm/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/sharepoint-three-vm/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/sharepoint-three-vm/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/sharepoint-three-vm/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/sharepoint-three-vm/CredScanResult.svg)

This template creates three new Azure VMs, each with a public IP address and load balancer and a VNet, it configures one VM to be an AD DC for a new Forest and Domain, one with SQL Server 2014 SP1 domain joined and a third VM with a Sharepoint 2013 farm and site, all VMs have public facing RDP

Click the button below to deploy

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-three-vm%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-three-vm%2Fazuredeploy.json)

Notes: Sharepoint farm name must not contain spaces.


