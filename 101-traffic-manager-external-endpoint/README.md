# Azure Traffic Manager with external endpoints

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-traffic-manager-external-endpoint/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-traffic-manager-external-endpoint/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-traffic-manager-external-endpoint/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-traffic-manager-external-endpoint/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-traffic-manager-external-endpoint/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-traffic-manager-external-endpoint/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-traffic-manager-external-endpoint%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-traffic-manager-external-endpoint%2Fazuredeploy.json)

This template shows how to create an Azure Traffic Manager profile using external endpoints and the performance traffic routing method.  To enable performance-based traffic routing, each endpoint needs an "endpointLocation" that specifies the closest Azure region.

The accompanying PowerShell script shows how to create a resource group from the template and read back the Traffic Manager profile details.  Before running the script, edit *azuredeploy.parameters.json* and replace the values marked with *'#####'*.

See also:

- <a href="https://azure.microsoft.com/en-us/documentation/articles/traffic-manager-routing-methods/">Traffic Manager routing methods for details of the different routing methods available.
- <a href="https://msdn.microsoft.com/en-us/library/azure/mt163581.aspx">Create or update a Traffic Manager profile for details of the JSON elements relating to a Traffic Manager profile.



