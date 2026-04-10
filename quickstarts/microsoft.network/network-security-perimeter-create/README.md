---
description: This template creates a network security perimeter and it's associated resource for protecting an Azure Key Vault.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: network-security-perimeter-create
languages:
- json
- bicep
---

# Create a network security perimeter

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/network-security-perimeter-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/network-security-perimeter-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/network-security-perimeter-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/network-security-perimeter-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/network-security-perimeter-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/network-security-perimeter-create/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/network-security-perimeter-create/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnetwork-security-perimeter-create%2Fazuredeploy.jsonn)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnetwork-security-perimeter-create%2Fazuredeploy.jsonn)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnetwork-security-perimeter-create%2Fazuredeploy.jsonn)


## Notes

[Azure Private Link FAQ](https://docs.microsoft.com/azure/private-link/private-link-faq)

[Network security perimeter service template format](https://docs.microsoft.com/azure/templates/microsoft.network/networksecurityperimeters)

`Tags: Microsoft.Network/networkSecurityPerimeters, Microsoft.Network/networkSecurityPerimeters/profiles, Microsoft.Network/networkSecurityPerimeters/profiles/accessRules, Microsoft.Network/networkSecurityPerimeters/resourceAssociations, Microsoft.KeyVault/vaults`