# Use a Secret from Key Vault with a Dynamic Reference

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-key-vault-use-dynamic-id/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-key-vault-use-dynamic-id/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-key-vault-use-dynamic-id/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-key-vault-use-dynamic-id/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-key-vault-use-dynamic-id/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-key-vault-use-dynamic-id/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-key-vault-use-dynamic-id%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-key-vault-use-dynamic-id%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template creates a SQL Server and uses an admin password from Key Vault.  The reference parameter for the Key Vault secret is created at deployment time using a nested template.  This allows the user to simply pass parameter values to the template rather than create a reference parameter in the parameter file.

More documentation can be found [here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-keyvault-parameter).

Tags: Azure Key Vault, Key Vault

