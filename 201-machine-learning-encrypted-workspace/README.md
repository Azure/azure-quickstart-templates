# Blank Template

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-machine-learning-encrypted-workspace/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-machine-learning-encrypted-workspace/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-machine-learning-encrypted-workspace/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-machine-learning-encrypted-workspace/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-machine-learning-encrypted-workspace/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-machine-learning-encrypted-workspace/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-machine-learning-encrypted-workspace%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-machine-learning-encrypted-workspace%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"/>
</a>

This template creates an Azure Machine Learning workspace with the following configurations:

* confidential_data: Enabling this turns on the following behavior in your Azure Machine Learning workspace:

    * Starts encrypting the local scratch disk for Azure Machine Learning compute clusters, providing you have not created any previous clusters in your subscription. If you have previously created a cluster in the subscription, open a support ticket to have encryption of the scratch disk enabled for your compute clusters.
    * Cleans up the local scratch disk between runs.
    * Securely passes credentials for the storage account, container registry, and SSH account from the execution layer to your compute clusters by using key vault.
    * Enables IP filtering to ensure the underlying batch pools cannot be called by any external services other than AzureMachineLearningService.

    For more information,, see [encryption at rest](https://docs.microsoft.com/azure/machine-learning/concept-enterprise-security#encryption-at-rest).

* encryption_status: Enables you to use your own (customer-managed) key to [encrypt the Azure Cosmos DB instance](https://docs.microsoft.com/azure/machine-learning/concept-enterprise-security#azure-cosmos-db) used by the workspace.

    * cmk_keyvault: The Azure Resource Manager ID of an existing Azure Key Vault. This key vault must contain an encryption key, which is used to encrypt the Cosmos DB instance.
    * resource_cmk_uri: The URI of the encryption key stored in the key vault.

    When using a customer-managed key, Azure Machine Learning creates a secondary resource group which contains the Cosmos DB instance. For more information, see [encryption at rest - Cosmos DB](https://docs.microsoft.com/en-us/azure/machine-learning/concept-enterprise-security#encryption-at-rest).

## Prerequisites

Before using this template, you must meet the following requirements:

* The __Azure Machine Learning__ application must have __contributor__ access to your Azure subscription.
* You must have an existing Azure Key Vault that contains an encryption key.
* The Azure Key Vault must exist in the same Azure region where you will create the Azure Machine Learning workspace.
* You must have an access policy in Azure Key Vault that grants __get__, __wrap__, and __unwrap__ access to the __Azure Cosmos DB__ application.

For more information, see [Encryption at rest](https://docs.microsoft.com/azure/machine-learning/concept-enterprise-security#data-encryption) and [Configure customer-managed keys for Azure Cosmos](https://docs.microsoft.com/azure/cosmos-db/how-to-setup-cmk).

`Tags: Azure Machine Learning, Machine Learning, encryption`