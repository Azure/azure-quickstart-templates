# Deploy A Linux or Windows VMSS with a Managed Service Identity

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-msi/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-msi/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-msi/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-msi/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-msi/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-msi/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-msi%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)]( https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-msi%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-msi%2Fazuredeploy.json)

This template shows how to use Managed Service Idenity with VM Scale Sets and how to access azure resources from within VMs in the Scale Set, in particular it shows how to:

- Create a VM SCale Set with a system assigned idenity
- Install the MSI extension to allow OAuth tokens to be issued for Azure resources
- Assign RBAC permissions to the Managed Identity
- Run a  script that uses the Azure CLI or PowerShell with the MSI

This template creates a new VM Scale Set with a MSI and deploys the MSI extension to each VM. The MSI associated with the VM Scale Set is given contributor permission on a storage account that is created by the template.  A script is then run on the VM using the customscript extension.  On Linux, this script installs Docker and then creates a container with the Azure CLI 2, it runs a script in this container that logs in to the CLI using the token issuing endpoint installed in the VM by the MSI extension. It then uses the cli to retrieve the keys for the storage account and writes a blob with a name matching the VM name into the storage account.  On Windows, the script uses PowerShell.

In order to make sure that the MSI is created and given permissions before the scripts run first the VM Scale Set is created with 0 instances, the MSI is then given RBAC permissions and then the VS Scale Set is updated to create the VMs with the extensions.

The default configuration will deploy a scaleset with 2 DS1_V2 VMs.


