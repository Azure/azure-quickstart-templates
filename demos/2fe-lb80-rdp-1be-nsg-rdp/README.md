# Create 2 Windows VMs in load balancing with port 80 open and a backend VM with SQL Server 2014.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/2fe-lb80-rdp-1be-nsg-rdp/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/2fe-lb80-rdp-1be-nsg-rdp/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/2fe-lb80-rdp-1be-nsg-rdp/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/2fe-lb80-rdp-1be-nsg-rdp/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/2fe-lb80-rdp-1be-nsg-rdp/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/2fe-lb80-rdp-1be-nsg-rdp/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2F2fe-lb80-rdp-1be-nsg-rdp%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2F2fe-lb80-rdp-1be-nsg-rdp%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2F2fe-lb80-rdp-1be-nsg-rdp%2Fazuredeploy.json)

This template creates 2 Windows VMs with in an Availability Set and a Load Balancer with port 80 open and two RDP connection for the two VMs with port 6001 and 6002 open. It also creates a SQL Server 2014 VM with a NIC that uses a NSG where is defined a Inbound rule for an RDP connection.


