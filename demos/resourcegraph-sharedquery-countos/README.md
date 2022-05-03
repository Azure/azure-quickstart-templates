# Resource Graph Shared Query - Count OS

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/resourcegraph-sharedquery-countos/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/resourcegraph-sharedquery-countos/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/resourcegraph-sharedquery-countos/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/resourcegraph-sharedquery-countos/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/resourcegraph-sharedquery-countos/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/resourcegraph-sharedquery-countos/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fresourcegraph-sharedquery-countos%2Fazuredeploy.json)  [![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fresourcegraph-sharedquery-countos%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fresourcegraph-sharedquery-countos%2Fazuredeploy.json)

This template deploys a **Resource Graph shared query**.

## Overview

This template deploys an Azure Resource Graph shared query. The shared query counts all virtual
machines, and then summarizes the title broken down by Operating System (OS).

```kusto
Resources
| where type =~ 'Microsoft.Compute/virtualMachines'
| summarize count() by tostring(properties.storageProfile.osDisk.osType)
```

This query can be manually run through the following methods:

- Azure CLI

  ```azurecli
  az graph query -q "Resources | where type =~ 'Microsoft.Compute/virtualMachines' | summarize count() by tostring(properties.storageProfile.osDisk.osType)"
  ```

- Azure PowerShell

  ```powershell
  Search-AzGraph -Query "Resources | where type =~ 'Microsoft.Compute/virtualMachines' | summarize count() by tostring(properties.storageProfile.osDisk.osType)"
  ```

- Portal

  - Azure portal:
    [portal.azure.com](https://portal.azure.com/?feature.customportal=false#blade/HubsExtension/ArgQueryBlade/query/Resources%20%7C%20where%20type%20%3D~%20'Microsoft.Compute%2FvirtualMachines'%20%7C%20summarize%20count()%20by%20tostring(properties.storageProfile.osDisk.osType))
  - Azure Government portal:
    [portal.azure.us](https://portal.azure.us/?feature.customportal=false#blade/HubsExtension/ArgQueryBlade/query/Resources%20%7C%20where%20type%20%3D~%20'Microsoft.Compute%2FvirtualMachines'%20%7C%20summarize%20count()%20by%20tostring(properties.storageProfile.osDisk.osType))
  - Azure China portal:
    [portal.azure.cn](https://portal.azure.cn/?feature.customportal=false#blade/HubsExtension/ArgQueryBlade/query/Resources%20%7C%20where%20type%20%3D~%20'Microsoft.Compute%2FvirtualMachines'%20%7C%20summarize%20count()%20by%20tostring(properties.storageProfile.osDisk.osType))

### Microsoft.ResourceGraph

The _Microsoft.ResourceGraph_ resource provider is used by Resource Graph Explorer in the portal to
save shared queries. A shared query is an Azure Resource Manager object while a private query is
stored in a users profile.

- **queries**: This is the resource type of a shared query used in Azure Resource Graph Explorer.

## Deployment steps

You can click the "Deploy to Azure" button at the beginning of this document or follow the
instructions for command line deployment using the scripts in the root of this repo.

## Notes

If you are new to Azure Resource Graph, see:

- [Azure Resource Graph documentation](https://docs.microsoft.com/azure/governance/resource-graph/)
- [Azure Resource Graph - Understand the query language](https://docs.microsoft.com/azure/governance/resource-graph/concepts/query-language)
- [Azure Resource Graph - Starter queries](https://docs.microsoft.com/azure/governance/resource-graph/samples/starter?tabs=azure-portal)
- [Azure Resource Graph - Advanced queries](https://docs.microsoft.com/azure/governance/resource-graph/samples/advanced?tabs=azure-portal)
- [Azure Resource Graph - Get resource changes](https://docs.microsoft.com/en-us/azure/governance/resource-graph/how-to/get-resource-changes)

If you are new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
- [Quickstart: Create a shared query by using an ARM template](https://docs.microsoft.com/azure/governance/resource-graph/shared-query-template)

`Tags: Resource Graph, KQL, query`
