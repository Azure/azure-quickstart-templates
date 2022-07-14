---
description: This template creates a new Azure VM, it configures the VM to be an Active Directory Domain Controller for a new forest
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: modules-active-directory-new-domain-0.9
languages:
- json
---
# Create an Azure VM with a new Active Directory Forest

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/active-directory-new-domain/0.9/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/active-directory-new-domain/0.9/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/active-directory-new-domain/0.9/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/active-directory-new-domain/0.9/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/active-directory-new-domain/0.9/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/active-directory-new-domain/0.9/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2Factive-directory-new-domain%2F0.9%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2Factive-directory-new-domain%2F0.9%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2Factive-directory-new-domain%2F0.9%2Fazuredeploy.json)

This module creates an Active Directory Domain Controller with a new forest, domain and DC.

This is an experimental module at the moment...

## Parameters

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| adminUsername | string | Yes | The name of the administrator account of the new VM and domain.|
| adminPassword | securestring | Yes | The password for the administrator account of the new VM and domain.|
| domainName | string | Yes | The FQDN of the Active Directory Domain to be created.|
| dnsPrefix | string | No | The DNS prefix for the public IP address used by the Load Balancer.|
| vmSize | string | No | Size of the VM for the controller.|
| _artifactsLocation | string | No | The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.|
| _artifactsLocationSasToken | securestring | No | The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.|
| location | string | No | Specifies the Azure location where the resources will be created. |
| virtualMachineName | string | No | The name of the AD Virtual Machine.|
| virtualNetworkName | string | No | The name of the virtualNetwork.|
| subnetName | string | No | The name of the subnet.|
| virtualNetworkAddressRange | string | No | Virtual network address range.|
| privateIPAddress  | string | No | Private IP Address of the DNS server.|
| subnetRange  | string | No | Subnet IP range.|

## Outputs

| Name | Type | Description |
| :------------- | :----------: | :------------- |
| dnsIpAddress | string | The IP address of the DNS server. The value of the privateIpAddress parameter. |
| domainName | string | The FQDN of the domain. The value of the domainName parameter. |
| virtualNetworkSubscriptionId | string | SubscriptionId of the virtualNetwork. The value of subscription().subscriptionId. |
| virtualNetworkResourceGroupName | string | Name of the resourceGroup for the virtualNetwork.  The value of resourceGroup().name |
| virtualNetworkName | string | Name of the virtualNetwork.  The value of the virtualNetworkName parameter. |
| subnetName | string | The name of the subnet.|
| virtualNetworkAddressPrefixes | array | Address ranges for the virtualNetwork. The value of the virtualNetworkAddressRanges parameter. |

```apiVersion: n/a```

`Tags: Microsoft.Network/publicIPAddresses, Microsoft.Compute/availabilitySets, Microsoft.Resources/deployments, Microsoft.Network/loadBalancers, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, extensions, DSC, Microsoft.Network/virtualNetworks`