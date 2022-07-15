---
description: This template shows how to create an Azure Traffic Manager profile using nested endpoints with min-child and multi-value routing.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: traffic-manager-minchild
languages:
- json
---
# Azure Traffic Manager multi-value routing

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-minchild/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-minchild/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-minchild/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-minchild/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-minchild/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-minchild/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ftraffic-manager-minchild%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ftraffic-manager-minchild%2Fazuredeploy.json)

This template shows how to create an Azure Traffic Manager profile using nested endpoints and the multi-value traffic routing method. The min-child feature is also deployed as part of the template.

## Notes

- [Traffic Manager routing methods](https://docs.microsoft.com/azure/traffic-manager/traffic-manager-routing-methods): Traffic Manager routing methods for details of the different routing methods available
- [Traffic Manager REST](https://docs.microsoft.com/rest/api/trafficmanager/): Create or update a Traffic Manager profile for details of the JSON elements relating to a Traffic Manager profile.

`Tags: Microsoft.Network/trafficManagerProfiles, Microsoft.Network/trafficManagerProfiles/nestedEndpoints, Microsoft.Network/TrafficManagerProfiles/ExternalEndpoints`
