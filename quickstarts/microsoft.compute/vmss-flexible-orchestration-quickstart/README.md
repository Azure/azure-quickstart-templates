# Virtual Machine Scale Sets Quickstart Flexible Orchestration Mode

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-flexible-orchestration-quickstart/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-flexible-orchestration-quickstart/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-flexible-orchestration-quickstart/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-flexible-orchestration-quickstart/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-flexible-orchestration-quickstart/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-flexible-orchestration-quickstart/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-flexible-orchestration-quickstart/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-flexible-orchestration-quickstart%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-flexible-orchestration-quickstart%2Fazuredeploy.json)   



This template deploys a simple VM Scale Set with instances behind an Azure Load Balancer. The VM Scale set is in Flexible Orchestration Mode. Use the os parameter to choose Linux (Ubuntu) or Windows (Windows Server Datacenter 2019) deployment. NOTE: This quickstart template enables network access to VM management ports (SSH, RDP) from any internet address, and should not be used for production deployments. For Network security best practices for production deployments, see [Azure Network Security Best Practices](https://docs.microsoft.com/en-us/azure/security/fundamentals/network-best-practices)

`Tags:Managed Disks, Azure VMs, VMSS`


