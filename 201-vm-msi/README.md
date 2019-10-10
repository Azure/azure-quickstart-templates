# Deploy A Linux or Windows VM with a Managed Service Identity

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-msi/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-msi/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-msi/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-msi/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-msi/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-msi/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-msi%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>

This shows how to use Managed Service Idenity from within a VM to access azure resources, in particular it shows how to:

- Create a VM with a system assigned idenity
- Install the MSI extension on the VM to allow OAuth tokens to be issued for Azure resources
- Assign RBAC permissions to the Managed Identity
- Run a script that uses Azure CLI or PowerShell to login using the MSI

This template creates a new VM with a MSI and deploys the MSI extension to the VM. The MSI associated with the VM is given contributor permission on a storage account that is created by the template. A script is then run on the VM using the customscript extension.  On Linux this script installs Docker and then creates a container with the Azure CLI 2, it runs a script in this container that logs in to the CLI using the token issuing endpoint installed in the VM by the MSI extension. It then uses the cli to retrieve the keys for the storage account and writes a blob with a name matching the VM name into the storage account.  On Windows, PowerShell is used.

