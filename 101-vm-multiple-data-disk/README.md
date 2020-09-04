# Create a Virtual Machine from a Windows Image with 4 Empty Data Disks

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-multiple-data-disk/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-multiple-data-disk/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-multiple-data-disk/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-multiple-data-disk/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-multiple-data-disk/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-multiple-data-disk/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-multiple-data-disk%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-multiple-data-disk%2Fazuredeploy.json)

This template allows you to create a Windows Virtual Machine from a specified image during the template deployment and install the VM Diagnostics Extension. It also attaches 4 empty data disks. Note that you can specify the size of each of the empty data disks. This template also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface.

NOTE: The configuration of the VM diagnostics extension relies on a Base64 encoded string for the xmlConfig. This configures a basic set of counters, including CPU and Memory. 


