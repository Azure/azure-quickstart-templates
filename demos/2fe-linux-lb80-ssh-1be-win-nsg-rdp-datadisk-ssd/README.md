# Create 2 Linux VMs in load balancing with port 80 open and a backend VM with SQL Server 2014 with 2 data disk as Premium Storage (SSD).

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2F2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2F2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2F2fe-linux-lb80-ssh-1be-win-nsg-rdp-datadisk-ssd%2Fazuredeploy.json)

This template creates 2 Linux VMs with in an Availability Set and a Load Balancer with port 80 open and two SSH connection for the two VMs with port 6001 and 6002 open. It also creates a SQL Server 2014 VM with a NIC that uses a NSG where is defined a Inbound rule for an RDP connection and also 2 data disk are mounted on the SQL Server VM with different caching levels.
All VMs storage can use Premium Storage (SSD) and you can choose to creare VMs with all DS sizes.


