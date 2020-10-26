# Azure Machine Learning secured workspace & encryption

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-machine-learning-encrypted-workspace/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-machine-learning-encrypted-workspace/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-machine-learning-encrypted-workspace/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-machine-learning-encrypted-workspace/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-machine-learning-encrypted-workspace/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-machine-learning-encrypted-workspace/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-machine-learning-encrypted-workspace%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-machine-learning-encrypted-workspace%2Fazuredeploy.json)

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

## Setup

Before using this template, you must meet the following requirements:

* The __Azure Machine Learning__ service principal must have __contributor__ access to your Azure subscription.
* You must have an existing Azure Key Vault that contains an encryption key.
* The Azure Key Vault must exist in the same Azure region where you will create the Azure Machine Learning workspace.
* You must have an access policy in Azure Key Vault that grants __get__, __wrap__, and __unwrap__ access to the __Azure Cosmos DB__ application.

### Add Azure Machine Learning as a contributor

To add the Azure Machine Learning service principal as a contributor to your subscription, use the following steps:

1. Use the [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) or [Azure Powershell](https://docs.microsoft.com/powershell/azure/install-az-ps) to authenticate to get your subscription ID:

Azure CLI

```Bash
    az account list --query '[].[name,id]' --output tsv
```

PowerShell

```powershell
    Get-AzSubscription
```

From the list of subscriptions, select the one you want to use and copy the subscription ID.

1. To get the object ID of the `Azure Machine Learning` service principal, use one off the following commands:

Azure CLI

```Bash
    az ad sp list --display-name "Azure Machine Learning" --query '[].[appDisplayName,objectId]' --output tsv
```

PowerShell

```powershell
    Get-AzADServicePrincipal --DisplayName "Azure Machine Learning" | select-object DisplayName, Id
```

Save the ID for the `Azure Machine Learning` entry.

1. To add the service principal as a contributor to your subscription, use one of the following commands. Replace the `<subscription-ID>` with your subscription ID and `<object-ID>` with the ID for the service principal:

Azure CLI

```Bash
    az role assignment create --role 'Contributor' --assignee-object-id <object-ID> --subscription <subscription-ID>
```

PowerShell

```powershell
    New-AzRoleAssignment --ObjectId <object-ID> --RoleDefinitionName "Contributor" -Scope /subscriptions/<subscription-ID>
```

### Add a key for encryption

To generate a key in an existing Azure Key Vault, use the [prereq template](prereqs/prereq.azuredeploy.json) provide with this sample or one of the following commands. Replace `<keyvault-name>` with the name of the key vault. Replace `<key-name>` with the name to use for the key:

Azure CLI

```Bash
    az keyvault key create --vault-name <keyvault-name> --name <key-name> --protection software
```

PowerShell

```powershell
    Add-AzKeyVaultKey -VaultName <keyvault-name> -Name <key-name> -Destination 'Software'
```

### Enable customer-managged keys for Azure Cosmos DB

See data encryption section of [Enterprise Security for Azure Machine Learning](https://docs.microsoft.com/azure/machine-learning/concept-enterprise-security#data-encryption) and [Configure customer-managed keys for your AzureCosmos account](https://docs.microsoft.com/azure/cosmos-db/how-to-setup-cmk).

### Add an access policy to the key vault

To add an access policy for Azure Cosmos DB to the key vault, use the following steps:

1. To get the object ID of the `Azure Cosmos DB` service principal, use one off the following commands:

Azure CLI

```Bash
    az ad sp list --display-name "Azure Cosmos DB" --query '[].[appDisplayName,objectId]' --output tsv
```

PowerShell

```powershell
    Get-AzADServicePrincipal --DisplayName "Azure Cosmos DB" | select-object DisplayName, Id
```

Save the ID for the `Azure Cosmos DB` entry.

1. To set the policy, use the following command. Replace `<keyvault-name>` with the name of the key vault. Replace `<object-ID>` with the ID for the service principal:

Azure CLI

```bash
    az keyvault set-policy --name <keyvault-name> --object-id <object-ID> --key-permissions get unwrapKey wrapKey
```

PowerShell

```powershell
    Set-AzKeyVaultAccessPolicy -VaultName <keyvault-name> -ObjectId <object-ID> -PermissionsToKeys get, unwrapKey, wrapKey
```

### Look up cmk_keyvault and resource_cmk_uri

Use this command to see cmk_keyvault.

Azure CLI: Id at the beginning of output is cmk_keyvault. Like this: /subscriptions/<subscripiton id>/resourceGroup/<rg name>/providers/Microsoft.KeyVault/vaults/<keyvault-name>.

```bash
    az keyvault show --name <keyvault-name>
```

PowerShell: Resource id  is cmk_keyvault. Like this: /subscriptions/<subscripiton id>/resourceGroup/<rg name>/providers/Microsoft.KeyVault/vaults/<keyvault-name>.

```powershell
    Get-AzureRMKeyVault -VaultName '<keyvault-name>'
```
Use this command to see resource_cmk_uri.

Azure CLI: kid is resource_cmk_uri. Like this: https://<keyvault-name>.vault.azure.net/keys/<key-name>/******.

```bash
    az keyvault key show --vault-name <keyvault-name> --name <key-name> 
```

PowerShell: Id is resource_cmk_uri. Like this: https://<keyvault-name>.vault.azure.net/keys/<key-name>/******.

```powershell
    Get-AzureKeyVaultKey -VaultName '<keyvault-name>' -KeyName '<key-name>'

## More information

* [Encryption at rest](https://docs.microsoft.com/azure/machine-learning/concept-enterprise-security#data-encryption)
* [Configure customer-managed keys for Azure Cosmos](https://docs.microsoft.com/azure/cosmos-db/how-to-setup-cmk).

`Tags: Azure Machine Learning, Machine Learning, encryption`
