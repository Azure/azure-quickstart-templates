---
description: This template deploys an Ubuntu Server with a few options for the VM. You can provide the VM Name, OS Version, VM size, and admin username and password. As default the VM size is Standard_D2s_v3 and OS version is 20.04-LTS.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vm-simple-linux
languages:
- bicep
- json
---
# Deploy a simple Ubuntu Linux VM 20.04-LTS

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-simple-linux/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-simple-linux/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-simple-linux/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-simple-linux/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-simple-linux/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-simple-linux/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-simple-linux/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-simple-linux%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-simple-linux%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-simple-linux%2Fazuredeploy.json)

This template deploys a **Linux VM Ubuntu** using the latest patched version. This will deploy a Standard_B2s size VM and a 20.04-LTS as default value in the resource group location and will return the admin user name, SSH command, and FQDN.

If you are new to Azure virtual machines, see:

- [Azure Virtual Machines](https://azure.microsoft.com/services/virtual-machines/).
- [Azure Virtual Machines documentation](https://learn.microsoft.com/azure/virtual-machines/)
- [Template reference](https://learn.microsoft.com/azure/templates/microsoft.compute/allversions)
- [Quickstart templates](https://learn.microsoft.com/en-us/samples/browse/?expanded=azure&products=azure-resource-manager)

If you are new to template deployment, see:

- [Azure Resource Manager documentation](https://learn.microsoft.com/azure/azure-resource-manager/)
- [Quickstart: Create an Ubuntu Linux virtual machine using an ARM template](https://learn.microsoft.com/azure/virtual-machines/linux/quick-create-template)

`Tags: Azure4Student, virtual machine, Linux, Ubuntu Server, Beginner, Microsoft.Network/networkInterfaces, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/virtualNetworks/subnets, Microsoft.Network/publicIPAddresses, Microsoft.Compute/virtualMachines`
