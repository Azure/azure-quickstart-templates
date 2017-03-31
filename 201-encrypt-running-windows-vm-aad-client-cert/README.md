# Enable encryption on a running Windows VM. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-windows-vm-aad-client-cert%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-windows-vm-aad-client-cert%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/AzureGov.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-running-windows-vm-aad-client-cert%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template enables encryption on a running windows vm using AAD client cert thumbprint. The certificate should have been deployed to the VM before running this template. This template assumes that the VM is located in the same region as the resource group. If not, please edit the template to pass appropriate location for the VM sub-resources.
