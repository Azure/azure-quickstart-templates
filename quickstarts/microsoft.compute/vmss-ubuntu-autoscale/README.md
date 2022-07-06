---
description: This template allows you to deploy a simple VM Scale Set of Linux VMs using the latest patched version of Ubuntu Linux 15.04 or 14.04.4-LTS. These VMs are behind a load balancer with NAT rules for ssh connections.They also have Auto Scale integrated
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vmss-ubuntu-autoscale
languages:
- json
---
# Deploy a VM Scale Set with Linux VMs and Auto Scale

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-ubuntu-autoscale/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-ubuntu-autoscale/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-ubuntu-autoscale/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-ubuntu-autoscale/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-ubuntu-autoscale/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-ubuntu-autoscale/CredScanResult.svg)

The following template deploys a Linux VM Scale Set integrated with Azure autoscale

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-ubuntu-autoscale%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-ubuntu-autoscale%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-ubuntu-autoscale%2Fazuredeploy.json)

The template deploys a Linux VMSS with a desired count of VMs in the scale set. Once the VM Scale Sets is deployed, user can deploy an application inside each of the VMs (either by directly logging into the VMs or via a custom script extension)

The Autoscale rules are configured as follows

- sample for CPU (\\Processor\\PercentProcessorTime) in each VM every 1 Minute
- if the Percent Processor Time is greater than 50% for 5 Minutes, then the scale out action (add more VM instances, one at a time) is triggered
- once the scale out action is completed, the cool down period is 1 Minute

`Tags: Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/loadBalancers, Microsoft.Compute/virtualMachineScaleSets, Microsoft.Insights/autoscaleSettings, ChangeCount`
