# Create an Azure SQL instance with data encryption protector activated

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sql-encryption-protector-byok/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sql-encryption-protector-byok/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sql-encryption-protector-byok/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sql-encryption-protector-byok/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sql-encryption-protector-byok/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sql-encryption-protector-byok/CredScanResult.svg" />&nbsp;

This template creates an Azure SQL server, and activate the data encryption protector with the "bring your own key". For that, you will need to provide the Key Vault, and the Key to use.

Click the button below to deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fsql-encryption-protector-byok%2Fazuredeploy.json" target="_blank">
    <img src="https://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fsql-encryption-protector-byok%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

In order to use an already in place Key Vault, it needs to have the property "soft-delete" enable. You can only do that using command lines (either [Powershell](https://docs.microsoft.com/en-US/azure/key-vault/key-vault-soft-delete-powershell) or [CLI](https://docs.microsoft.com/en-US/azure/key-vault/key-vault-soft-delete-cli))

Alternatively, you can use the PowerShell file included in this directory to create a Key Vault and generate a key.

 Then, the arm template will achieve the following:
 * Create the Azure SQL server
 * Add the SQL server principalID access to the given Key Vault (permissions 'get', 'wrapLey' and 'unwrapKey')
 * Add a new key at the SQL server level, with the Key value from the Vault
 * And finally, activate the protector using the key created before

