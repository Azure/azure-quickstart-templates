---
description: This template allows you to deploy a Windows VM with Windows Admin Center extension to manage the VM directly from Azure Portal.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vm-windows-admincenter
languages:
- json
- bicep
---
# Deploy a Windows VM with Windows Admin Center extension

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-admincenter/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-admincenter/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-admincenter/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-admincenter/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-admincenter/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-admincenter/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-admincenter/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-windows-admincenter%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-windows-admincenter%2Fazuredeploy.json)

This template allows you to deploy a simple Windows [Generation 2 VM](https://docs.microsoft.com/azure/virtual-machines/generation-2) using a few different options for the Windows version, using the latest patched version. This will deploy a D2s_v3 size VM in the resource group location and return the fully qualified domain name of the VM.

The Virtual Machine has Windows Admin Center extension installed and can be directly managed within the Azure Portal using Windows Admin Center pane. See [documentation](https://docs.microsoft.com/windows-server/manage/windows-admin-center/azure/manage-vm) for instructions on how to use it.

In production environments, public IP should not be assigned directly to Virtual Machines and RDP/Windows Admin Center NSG rules should be restricted to allow access only to management machines.

If you're new to Azure virtual machines, see:

- [Use Windows Admin Center in the Azure portal to manage a Windows Server VM](https://docs.microsoft.com/windows-server/manage/windows-admin-center/azure/manage-vm)
- [Azure Virtual Machines](https://azure.microsoft.com/services/virtual-machines/)
- [Azure Windows Virtual Machines documentation](https://docs.microsoft.com/azure/virtual-machines/windows/)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.compute/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Compute&pageNumber=1&sort=Popular)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
- [Quickstart: Create a Windows virtual machine using an ARM template](https://docs.microsoft.com/azure/virtual-machines/windows/quick-create-template)

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, AdminCenter`
