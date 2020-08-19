# Windows VM Scale Set with Application Gateway Integration

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-windows-app-gateway/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-windows-app-gateway/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-windows-app-gateway/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-windows-app-gateway/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-windows-app-gateway/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-windows-app-gateway/CredScanResult.svg)

This template deploys a Windows VM Scale Set integrated with Azure Application Gateway.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-windows-app-gateway%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-windows-app-gateway%2Fazuredeploy.json)

The Application Gateway is configured for round robin load balancing of incoming connections at port 80 (of the gateway's public IP address) to VMs in the scale set.

Note that this template does not install an application on the VM Scale Set VMs, so if you want to demonstrate the round robin load balancing, the template will need to be updated (for example by adding an extension to install a web server).

This template supports VM scale sets of up to 1,000 VMs, and uses Azure Managed Disks.


