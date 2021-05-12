# Azure Traffic Manager with external endpoints

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-external-endpoint/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-external-endpoint/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-external-endpoint/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-external-endpoint/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-external-endpoint/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-external-endpoint/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ftraffic-manager-external-endpoint%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ftraffic-manager-external-endpoint%2Fazuredeploy.json)

This template shows how to create an Azure Traffic Manager profile using external endpoints and the performance traffic routing method. To enable performance-based traffic routing, each endpoint needs an `endpointLocation` that specifies the closest Azure region. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/traffic-manager/quickstart-create-traffic-manager-profile-template) article.

The accompanying PowerShell script shows how to create a resource group from the template and read back the Traffic Manager profile details.

## Notes

- [Traffic Manager routing methods](https://docs.microsoft.com/azure/traffic-manager/traffic-manager-routing-methods): Traffic Manager routing methods for details of the different routing methods available
- [Traffic Manager REST](https://docs.microsoft.com/rest/api/trafficmanager/): Create or update a Traffic Manager profile for details of the JSON elements relating to a Traffic Manager profile.
