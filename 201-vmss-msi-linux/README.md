# Deploy A Linux VMSS with MSI

This template shows how to use Managed Service Idenity with VM Scale Sets and how to access azure resources from within VMs in the Scale Set, in particular it shows how to:

- Create a VM SCale Set with a system assigned idenity
- Install the MSI extension to allow OAuth tokens to be issued for Azure resources
- Assign RBAC permissions to the Managed Identity
- Run a bash script that uses the Azure CLI with the MSI

This template creates a new Linux VM Scale Set with a MSI and deploys the MSI extension to each VM. The MSI associated with the VM Scale Set is given owner permission on a storage account that is created by the template. A shell script is then run on the VM using the customscript extension , this script installs Docker and then creates a container with the Azure CLI 2, it runs a script in this container that logs in to the CLI using the token issuing endpoint installed in the VM by the MSI extension. It then uses the cli to retrieve the keys for the storage account and writes a blob with a name matching the VM name into the storage account.

In order to make sure that the MSI is created and given permissions before the scripts run first the VM Scale Set is created with 0 instances, the MSI is then given RBAC permissions and then the VS Scale Set is updated to create the VMs with the extensions.

The default configuration will deploy a scaleset with 2 DS1_V2 VMs.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-msi-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

