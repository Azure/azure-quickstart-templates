---
description: This template allows you to deploy a trusted launch capable VM Scale Set of Windows VMs using the latest patched version of Windows Server 2016, Windows Server 2019 or Windows Server 2022 Azure Edition. These VMs are behind a load balancer with NAT rules for RDP connections. If you enable Secureboot and vTPM, the Guest Attestation extension will be installed on your VMSS. This extension will perform remote [attestation](https&#58;//docs.microsoft.com/en-us/windows/security/information-protection/tpm/tpm-fundamentals#measured-boot-with-support-for-attestation) by the cloud.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vmss-trustedlaunch-windows
languages:
- bicep
- json
---
# Deploy a trusted launch capable Windows VM Scale Set

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-trustedlaunch-windows/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-trustedlaunch-windows/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-trustedlaunch-windows/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-trustedlaunch-windows/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-trustedlaunch-windows/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-trustedlaunch-windows/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-trustedlaunch-windows/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-trustedlaunch-windows%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-trustedlaunch-windows%2FcreateUiDefinition.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-trustedlaunch-windows%2Fazuredeploy.json)

This template allows you to deploy a [trusted launch](https://docs.microsoft.com/azure/virtual-machines/trusted-launch) capable Windows virtual machine scale set using a few different options for the Windows version, using the latest patched version. If you enable Secureboot and vTPM, the Guest Attestation extension will be installed on your VM. This extension will perform remote [attestation](https://docs.microsoft.com/windows/security/information-protection/tpm/tpm-fundamentals#measured-boot-with-support-for-attestation) by the cloud. By default, this will deploy a Standard_D2_v3 size virtual machine in the resource group location and return the fully qualified domain name of the virtual machine.

If you're new to Azure virtual machines, see:

- [Azure Virtual Machine Scale Sets](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.compute/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Compute&pageNumber=1&sort=Popular)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
- [Quickstart: Create a Linux virtual machine scale set using an ARM template](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/flexible-virtual-machine-scale-sets-rest-api)

`Tags:Azure4Student, virtual machine scale set, Windows, Windows Server, Beginner, Trusted Launch, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachineScaleSets, Microsoft.Compute/virtualMachineScaleSets/extensions, [variables('extensionName')]`
