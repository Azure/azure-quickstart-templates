<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-key-vault-secret-create%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-key-vault-secret-create%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template helps you to create a Key Vault. It allows to create and set multiple access policies and Secrets while creating the Vault. If you are new to [Key Vault check this out](https://azure.microsoft.com/en-us/services/key-vault/). A full walk through of this template is available [here](http://www.rahulpnath.com/blog/managing-azure-key-vault-using-azure-resource-manager-arm-templates/).

Instead of just using an array for the secret creation, this template wraps an array in a [secureObject](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates#parameters).
Using a secureObject instead of an array type means that the values you pass, cannot be read back in the portal after the deployment. 

Tags: Azure Key Vault, Key Vault, Secrets
