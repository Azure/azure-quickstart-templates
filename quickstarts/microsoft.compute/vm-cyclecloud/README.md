# CycleCloud install using Bicep + Cloud-Init

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
