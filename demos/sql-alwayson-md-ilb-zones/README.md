# Create a SQL Server AlwaysOn Availability Group in an existing Azure VNET and Active Directory domain across Availability Zones using an Internal Load Balancer

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/sql-alwayson-md-ilb-zones/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/sql-alwayson-md-ilb-zones/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/sql-alwayson-md-ilb-zones/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/sql-alwayson-md-ilb-zones/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/sql-alwayson-md-ilb-zones/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/sql-alwayson-md-ilb-zones/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fsql-alwayson-md-ilb-zones%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fsql-alwayson-md-ilb-zones%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fsql-alwayson-md-ilb-zones%2Fazuredeploy.json)

This template will create a SQL Server AlwaysOn Availability Group using the PowerShell DSC Extension in an existing Azure Virtual Network and Active Directory environment. Both SQL Server 2016 and SQL Server 2017 are supported by this template. The SQL Server VMs will be provisioned across multiple Azure Availability Zones and requests will be directed to the Listener using the Internal Load Balancer (ILB) Standard.
