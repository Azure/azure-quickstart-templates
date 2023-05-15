---
description: This template allows you to deploy a trusted launch capable Windows virtual machine using a few different options for the Windows version, using the latest patched version. If you enable Secureboot and vTPM, the Guest Attestation extension will be installed on your VM. This extension will perform remote [attestation](https&#58;//docs.microsoft.com/en-us/windows/security/information-protection/tpm/tpm-fundamentals#measured-boot-with-support-for-attestation) by the cloud. By default, this will deploy an Standard_D2_v3 size virtual machine in the resource group location and return the FQDN of the virtual machine.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vm-trustedlaunch-windows
languages:
- bicep
- json
---
# Deploy a trusted launch capable Windows virtual machine

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-trustedlaunch-windows/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-trustedlaunch-windows/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-trustedlaunch-windows/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-trustedlaunch-windows/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-trustedlaunch-windows/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-trustedlaunch-windows/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-trustedlaunch-windows/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-trustedlaunch-windows%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-trustedlaunch-windows%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-trustedlaunch-windows%2Fazuredeploy.json)   

This template allows you to deploy a [trusted launch](https://docs.microsoft.com/azure/virtual-machines/trusted-launch) capable Windows virtual machine using a few different options for the Windows version, using the latest patched version. If you enable Secureboot and vTPM, the Guest Attestation extension will be installed on your VM. This extension will perform remote [attestation](https://docs.microsoft.com/windows/security/information-protection/tpm/tpm-fundamentals#measured-boot-with-support-for-attestation) by the cloud. By default, this will deploy a Standard_D2_v3 size virtual machine in the resource group location and return the fully qualified domain name of the virtual machine.

If you're new to Azure virtual machines, see:

- [Azure Virtual Machines](https://azure.microsoft.com/services/virtual-machines/)
- [Azure Linux Virtual Machines documentation](https://docs.microsoft.com/azure/virtual-machines/linux/)
- [Azure Windows Virtual Machines documentation](https://docs.microsoft.com/azure/virtual-machines/windows/)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.compute/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Compute&pageNumber=1&sort=Popular)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
- [Quickstart: Create a Windows virtual machine using an ARM template](https://docs.microsoft.com/azure/virtual-machines/windows/quick-create-template)

`Tags:Azure4Student, virtual machine, Windows, Windows Server, Beginner, Trusted Launch, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, SystemAssigned, Microsoft.Compute/virtualMachines/extensions, [variables('extensionName')]`
