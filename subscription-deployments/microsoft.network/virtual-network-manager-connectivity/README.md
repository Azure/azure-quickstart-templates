---
description: This template deploys an Azure Virtual Network Manager and sample virtual networks into the named resource group. It supports multiple connectivity topologies and network group membership types.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: virtual-network-manager-connectivity
languages:
- bicep
- json
---
# Create an Azure Virtual Network Manager and sample VNETs

This sample demonstrates using Bicep to deploy Azure Virtual Network Manager and example Virtual Networks with different connectivity topology and network group membership types. Use deployment parameters to specify the type of configuration to deploy.

In order to support deploying Azure Policy for dynamic group membership, this sample is designed to deploy at the subscription scope. However, this is not a requirement for Azure Virtual Network Manager if using static group membership.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-deployments%2Fmicrosoft.network%2Fvirtual-network-manager-create%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-deployments%2Fmicrosoft.network%2Fvirtual-network-manager-create%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-deployments%2Fmicrosoft.network%2Fvirtual-network-manager-create%2Fazuredeploy.json)

## Deploy sample from Bicep

**Prerequisites:**

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install#azure-cli) (should install automatically with Azure CLI)

### Download or Clone the Sample Bicep Files

#### Clone Sample Files Repo with Git

Prerequisites: [git](https://git-scm.com/downloads) must be installed

1. In a terminal, navigate to the directory where you would like to place a copy of the repository
1. Run command `git clone https://github.com/mspnp/samples.git mspnp-samples`
1. Change directories to the new `mspnp-samples` directory

#### Download Files

1. Navigate to the project GitHub [https://github.com/mspnp/samples](https://github.com/mspnp/samples)
1. Click the green **Code** button, then **Download Zip**
1. Download and extract the zip file
1. Change directories to the extracted zip file

### Deploy Bicep Template with Azure CLI

**AVMN Mesh and Hub and Spoke Connectivity with Static Network Group Membership**

Update the parameter values below for your preferred Resource Group name and deployment location.

```azurecli-interactive
az deployment subscription create \
    --template-file solutions/avnm-bicep-sample/bicep/main.bicep \
    --parameters resourceGroupName=rg-avnm-sample location=eastus
```

**AVMN Hub and Spoke Connectivity with Dynamic Network Group Membership**

Update the parameter values below for your preferred Resource Group name and deployment location.

```azurecli-interactive
az deployment subscription create \
    --template-file solutions/avnm-bicep-sample/bicep/main.bicep \
    --parameters resourceGroupName=rg-avnm-sample location=eastus connectivityTopology=hubAndSpoke networkGroupMembershipType=dynamic
```

## Solution deployment parameters

| Parameter | Type | Description | Default |
|---|---|---|--|
| `location` | string | Deployment location. Location must support availability zones. | `eastus` |
| `resourceGroupName` | string | The name of the resource group where AVMN will be deployed | `rg-avnm-sample` |
| `connectivityTopology` | string | Defines how spokes will connect to each other and how spokes will connect the hub. Valid values: "mesh", "hubAndSpoke", "meshWithHubAndSpoke" | `meshWithHubAndSpoke` |
| `networkGroupMembershipType` | string | Connectivity group membership type.| `static` |

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-network-manager-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-network-manager-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-network-manager-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-network-manager-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-network-manager-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-network-manager-create/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-network-manager-create/BicepVersion.svg)

`Tags: `