# Deploy a Terraform Workstation as a Linux VM with MSI

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-msi-linux-terraform/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-msi-linux-terraform/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-msi-linux-terraform/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-msi-linux-terraform/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-msi-linux-terraform/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-msi-linux-terraform/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-msi-linux-terraform%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-msi-linux-terraform%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-msi-linux-terraform%2Fazuredeploy.json)

This template creates a Terraform workstation as follows:

- Create a VM with system assigned identity based on the Ubuntu 17.10 image
- Install the MSI extension on the VM to allow OAuth tokens to be issued for Azure resources
- Assign RBAC permissions to the Managed Identity, granting owner rights for the resource group
- Installs Terraform Open Source
- Installs Azure CLI v2
- Creates a Terraform template folder (tfTemplate)
- Pre-configures Terraform remote state with the Azure backend
- Optionally installs Ubuntu Mate Desktop environment for development

This template creates a new Linux VM with a MSI and deploys the MSI extension to the VM. The MSI associated with the VM is given owner permission on the resource group containing the VM. A shell script is then run on the VM using the customscript extension. This shell script installs Terraform and Azure CLI v2. It then creates a Terraform template folder that is preconfigured to use Terraform Remote State with the Azure backend. The Azure CLI also creates the storage container required by remote state.  Optionally, this template installs Ubuntu Mate Desktop environment for usage as develolpment environment. 

### Steps to enable Remote State
Copy ~/tfTemplate/remoteState.tf from home directory to the root of the Terraform scripts to enable remote state management

### Steps to enable MSI
Once the template is deployed, log into the vm and run the following command to enable MSI with terraform

     `sh ~/tfEnv.sh`



