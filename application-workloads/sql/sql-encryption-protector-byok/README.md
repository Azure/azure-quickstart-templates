# Create an Azure SQL instance with data encryption protector activated

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sql-encryption-protector-byok/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sql-encryption-protector-byok/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sql-encryption-protector-byok/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sql-encryption-protector-byok/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sql-encryption-protector-byok/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sql-encryption-protector-byok/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsql%2Fsql-encryption-protector-byok%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsql%2Fsql-encryption-protector-byok%2Fazuredeploy.json)    

This template creates an Azure SQL server, and activate the data encryption protector with the "bring your own key". For that, you will need to provide the Key Vault, and the Key to use.

In order to use an already in place Key Vault, it needs to have the property "soft-delete" enable. You can only do that using command lines (either [Powershell](https://docs.microsoft.com/en-US/azure/key-vault/key-vault-soft-delete-powershell) or [CLI](https://docs.microsoft.com/en-US/azure/key-vault/key-vault-soft-delete-cli))

Alternatively, you can use the PowerShell file included in this directory to create a Key Vault and generate a key.

 Then, the arm template will achieve the following:
 * Create the Azure SQL server
 * Add the SQL server principalID access to the given Key Vault (permissions 'get', 'wrapLey' and 'unwrapKey')
 * Add a new key at the SQL server level, with the Key value from the Vault
 * And finally, activate the protector using the key created before


