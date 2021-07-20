# CycleCloud install using Bicep + Cloud-Init

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-cyclecloud/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-cyclecloud/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-cyclecloud/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-cyclecloud/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-cyclecloud/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-cyclecloud/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-cyclecloud/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-cyclecloud%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-cyclecloud%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-cyclecloud%2Fazuredeploy.json)

With [CycleCloud 8.1](https://techcommunity.microsoft.com/t5/azure-compute/azure-cyclecloud-8-1-is-now-available/ba-p/1898011) now supporting [Cloud-Init](https://cloud-init.io/) as a means of configuring VMs it seemed appropriate to look at using cloud-init in the deployment of CycleCloud itself.

This exemplar uses [Bicep](https://github.com/Azure/bicep) to deploy the Azure resources and has been tested with v0.2.14 (alpha). Much like Terraform, Bicep drastically simplifies the authoring experience and provides a transparent abstraction over ARM.

Just edit or supply parameters to override the defaults

Deployment steps

```bash
bicep build *.bicep
az deployment sub create --template-file sub.json --location uksouth --confirm-with-what-if 
az deployment group create --resource-group rg-bicep --template-file main.json --confirm-with-what-if 
```

With Bicep 0.2 the VSCode Bicep extension brings inbuilt intellisence which greatly simplifies adding resources and setting the required properties. Bicep will also determining the dependencies and perform error/consistency checking so a template such as this can be rapidly rapidly created.

This example uses the following resource types:

- Microsoft.Authorization/roleAssignments
- Microsoft.Compute/virtualMachines
- Microsoft.ManagedIdentity/userAssignedIdentities
- Microsoft.Network/networkInterfaces
- Microsoft.Network/networkSecurityGroups
- Microsoft.Network/publicIpAddresses
- Microsoft.Network/virtualNetworks
- Microsoft.Resources/resourceGroups
- Microsoft.Storage/storageAccounts

Note: Once the VM has been provisioned there will be a 3-5min delay while CycleCloud is installed and configured.

TODO: Clean up README

