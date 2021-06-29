# VM scale set based on the Azure Data Science VM 

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-datascience/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-datascience/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-datascience/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-datascience/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-datascience/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-datascience/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvmss-datascience%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvmss-datascience%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvmss-datascience%2Fazuredeploy.json)    

This template creates a VM scale set based on the Azure Marketplace [Windows 2016](https://azuremarketplace.microsoft.com/marketplace/apps/microsoft-ads.windows-data-science-vm?tab=Overview) and [Ubuntu 16.04-LTS](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/microsoft-ads.linux-data-science-vm-ubuntu?tab=Overview) Data Science VMs.

The template creates a scale set, a load balancer and a public IP address. Inbound NAT pools are defined to route incoming connections to the VMs in the set.

Inbound NAT rules are configured as follows:
```
SSH/RDP to the ip/dns address port 50000 to connect to VM#0
SSH/RDP to the ip/dns address port 50001 to connect to VM#1
etc..
```

![Windows 2016 screenshot](../demos/vmss-datascience/img/datasciencewin2016.PNG)

## Additional information

[Introduction to the Azure Data Science VM](https://docs.microsoft.com/azure/machine-learning/machine-learning-data-science-virtual-machine-overview)
