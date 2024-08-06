---
description: This template provides a way to deploy a Azure Database for MySQL Flexible Server with Private Endpoint.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: flexible-mysql-with-private-endpoint
languages:
- bicep
- json
---
# Deploy MySQL Flexible Server with Private Endpoint

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dbformysql/flexible-mysql-with-private-endpoint/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dbformysql/flexible-mysql-with-private-endpoint/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dbformysql/flexible-mysql-with-private-endpoint/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dbformysql/flexible-mysql-with-private-endpoint/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dbformysql/flexible-mysql-with-private-endpoint/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dbformysql/flexible-mysql-with-private-endpoint/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dbformysql/flexible-mysql-with-private-endpoint/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.dbformysql%2Fflexible-mysql-with-private-endpoint%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.dbformysql%2Fflexible-mysql-with-private-endpoint%2Fazuredeploy.json)

This template creates a private endpoint, Private DNS Zone and a virtual machine to test the private connection to an Azure Database for MySQL Flexible Server. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/mysql/flexible-server/quickstart-create-arm-template) article.

For more information about Private Link for Azure Database for MySQL - Flexible Server, see the [docs](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/concepts-networking-private-link)

`Tags: Microsoft.DBforMySQL/flexibleServers, Microsoft.DBforMySQL/flexibleServers/databases, Microsoft.Network/virtualNetworks, Microsoft.Network/virtualNetworks/subnets, Microsoft.Network/privateEndpoints, Microsoft.Network/privateDnsZones, Microsoft.Network/privateDnsZones/virtualNetworkLinks, Microsoft.Network/privateEndpoints/privateDnsZoneGroups, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines`
