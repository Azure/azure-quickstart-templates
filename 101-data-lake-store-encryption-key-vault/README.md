# Deploy a new Data Lake Store account.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-lake-store-encryption-key-vault%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to deploy an Azure Data Lake Store account with data encryption enabled. This account uses Azure Key Vault to manage the encryption key. To create an Azure Data Lake Store account with data encryption disabled, see [Deploy Azure Data Lake Store accounts with no data encryption](https://azure.microsoft.com/resources/templates/101-data-lake-store-no-encryption/). To create an Azure Data Lake Store account with data encryption (Azure Data Lake), see [Deploy Azure Data Lake Store accounts with data encryption using Azure Data Lake](https://azure.microsoft.com/resources/templates/101-data-lake-store-encryption-adls/). For more information about data encryption, see [Encryption of data in Azure Data Lake Store](https://docs.microsoft.com/azure/data-lake-store/data-lake-store-encryption).

This template needs an Azure Key Vault, a Key Vault encryption key, and the key version. To create a Key Vault and a key, see [Create a key vault](https://docs.microsoft.com/azure/key-vault/key-vault-get-started.md#vault)) and [Add a key or secret to the key vault](https://docs.microsoft.com/azure/key-vault/key-vault-get-started#add). The format of the key vault resource ID is "/subscriptions/<SubscriptionID>/resourceGroups/<ResourceGroupName>/providers/Microsoft.KeyVault/vaults/<KeyVaultName>". 
