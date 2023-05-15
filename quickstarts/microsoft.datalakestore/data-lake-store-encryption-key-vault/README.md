---
description: This template allows you to deploy an Azure Data Lake Store account with data encryption enabled.  This account uses Azure Key Vault to manage the encryption key.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: data-lake-store-encryption-key-vault
languages:
- json
---
# Deploy Data Lake Store account with encryption(Key Vault)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datalakestore/data-lake-store-encryption-key-vault/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datalakestore/data-lake-store-encryption-key-vault/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datalakestore/data-lake-store-encryption-key-vault/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datalakestore/data-lake-store-encryption-key-vault/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datalakestore/data-lake-store-encryption-key-vault/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datalakestore/data-lake-store-encryption-key-vault/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datalakestore%2Fdata-lake-store-encryption-key-vault%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datalakestore%2Fdata-lake-store-encryption-key-vault%2Fazuredeploy.json)

This template allows you to deploy an Azure Data Lake Store account with data encryption enabled. This account uses Azure Key Vault to manage the encryption key. To create an Azure Data Lake Store account with data encryption disabled, see [Deploy Azure Data Lake Store accounts with no data encryption](https://azure.microsoft.com/resources/templates/101-data-lake-store-no-encryption/). To create an Azure Data Lake Store account with data encryption (Azure Data Lake), see [Deploy Azure Data Lake Store accounts with data encryption using Azure Data Lake](https://azure.microsoft.com/resources/templates/101-data-lake-store-encryption-adls/). For more information about data encryption, see [Encryption of data in Azure Data Lake Store](https://docs.microsoft.com/azure/data-lake-store/data-lake-store-encryption).

This template needs an Azure Key Vault, a Key Vault encryption key, and the key version. To create a Key Vault and a key, see [Create a key vault](https://docs.microsoft.com/azure/key-vault/key-vault-get-started.md#vault)) and [Add a key or secret to the key vault](https://docs.microsoft.com/azure/key-vault/key-vault-get-started#add). The format of the key vault resource ID is "/subscriptions/<SubscriptionID>/resourceGroups/<ResourceGroupName>/providers/Microsoft.KeyVault/vaults/<KeyVaultName>".

`Tags: Microsoft.DataLakeStore/accounts, UserManaged, SystemAssigned, Microsoft.Resources/deployments, Microsoft.KeyVault/vaults/accessPolicies, Microsoft.ManagedIdentity/userAssignedIdentities, Microsoft.Authorization/roleAssignments, Microsoft.KeyVault/vaults, Microsoft.Resources/deploymentScripts, userAssigned`
