---
description: Create an Azure DNS record linked directly to an Azure Traffic Manager profile.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: traffic-manager-linked-record
languages:
- bicep
- json
---

# Create a Traffic Manager linked record

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-linked-record/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-linked-record/PublicDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-linked-record/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-linked-record/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/traffic-manager-linked-record/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ftraffic-manager-linked-record%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ftraffic-manager-linked-record%2Fazuredeploy.json)

This Bicep template creates an Azure DNS zone, a strictly typed Azure Traffic Manager profile with two external endpoints, and an Azure DNS A record linked directly to the Traffic Manager profile.

> [!IMPORTANT]
> Traffic Manager linked records are in preview. Preview features are provided under the [Supplemental Terms of Use for Microsoft Azure Previews](https://azure.microsoft.com/support/legal/preview-supplemental-terms/).

## Sample overview and deployed resources

The Traffic Manager profile uses priority routing and A records. The linked Azure DNS record returns the selected endpoint IPv4 address directly, without an intermediate CNAME lookup to `trafficmanager.net`.

The following resources are deployed:

- **Microsoft.Network/dnsZones**: A public Azure DNS zone.
- **Microsoft.Network/trafficManagerProfiles**: A strictly typed Traffic Manager profile with two external endpoints.
- **Microsoft.Network/dnsZones/A**: An A record linked to the Traffic Manager profile.

## Prerequisites

Provide two public IPv4 endpoints that answer HTTP health probes on port 80 at path `/`.

The `prereqs` folder supports automated validation. It deploys two temporary Azure Container Instances running the Azure Container Instances hello-world image and supplies their public IPv4 addresses to the main template.

## Deployment steps

Use the **Deploy to Azure** button, or deploy `main.bicep` with Azure CLI or Azure PowerShell. The repository generates `azuredeploy.json` from `main.bicep` after merge.

## Usage

Delegate the deployed zone to the Azure DNS name servers before using the linked record publicly. For validation without delegation, query one of the authoritative name servers returned by the deployment.

The linked record inherits its time-to-live value from the Traffic Manager profile. Azure DNS ignores the record set's `TTL` value when `trafficManagementProfile` is present.

`Tags: Azure DNS, Traffic Manager, linked record, Bicep`
