# Azure Machine Learning workspace (customer-managed key encryption)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-workspace-cmk/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-workspace-cmk/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-workspace-cmk/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-workspace-cmk/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-workspace-cmk/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-workspace-cmk/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Fmachine-learning-workspace-cmk%2Fazuredeploy.json)
[![Deploy To Azure Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Fmachine-learning-workspace-cmk%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Fmachine-learning-workspace-cmk%2Fazuredeploy.json)

This deployment template specifies an Azure Machine Learning workspace, and its associated resources including Azure Key Vault, Azure Storage, Azure Application Insights and Azure Container Registry.

This configuration describes the set of resources required to:

1. (prerequisite) Create and configure an Azure Key vault resource to host an encryption key for Azure Machine Learning.
1. Create an Azure Machine Learning workspace and dependent resources, and configure it for encryption with the above encryption key.

When using a customer-managed key, Azure Machine Learning creates a secondary resource group in your subscription which contains a Cosmos DB resource, an Azure Storage resource, and Azure Search resource. For more information, see [encryption at rest - Cosmos DB](https://docs.microsoft.com/en-us/azure/machine-learning/concept-enterprise-security#encryption-at-rest).

## Resources

| Provider and type | Description |
| - | - |
| `Microsoft.Insights/components` | An Azure Application Insights instance associated to the Azure Machine Learning workspace |
| `Microsoft.KeyVault/vaults` | An Azure Key Vault instance associated to the Azure Machine Learning workspace |
| `Microsoft.Storage/storageAccounts` | An Azure Storage instance associated to the Azure Machine Learning workspace |
| `Microsoft.ContainerRegistry/registries` | An Azure Container Registry instance associated to the Azure Machine Learning workspace |
| `Microsoft.MachineLearningServices/workspaces` | An Azure Machine Learning workspace instance |

## Variables

| Name | Description |
|-|-|
| name | Name of the deployment |
| environment | The prefix to add to resource names e.g. dev / test / prod. |
| location | The Azure region to use for deployments. |
| hbi_workspace | Specifies whether to reduce telemetry collection and enable additional encryption. |
| encryption_status | Specifies if the Azure Machine Learning workspace should be encrypted with a customer managed key. |
| cmk_keyvault | The Resource ID of an existing Azure Key Vault. This Key vault must contain an encryption key, which is used for encryption |
| cmk_keyvault_key_uri | The URI of the encryption key stored in the key vault. |

## Prerequisites

Before using this template, you must meet the following requirements:

* The __Azure Machine Learning__ service principal must have __contributor__ access to your Azure subscription.
* You must have an existing Azure Key Vault that contains an encryption key.
* The Azure Key Vault must exist in the same Azure region where you will create the Azure Machine Learning workspace.
* You must have an access policy in Azure Key Vault that grants __get__, __wrap__, and __unwrap__ access to the __Azure Cosmos DB__ application.

To add the Azure Machine Learning service principal as a contributor to your subscription, you can use the following steps in the Azure CLI or Powershell for automation. Alternatively complete the steps via the Azure Portal.


### Add Azure Machine Learning as a contributor

1. Use the [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) or [Azure Powershell](https://docs.microsoft.com/powershell/azure/install-az-ps) to authenticate to get your subscription ID:

Azure CLI:

```Bash
    az account list --query '[].[name,id]' --output tsv
```

PowerShell:

```powershell
    Get-AzSubscription
```

From the list of subscriptions, select the one you want to use and copy the subscription ID and save the ID for the `Azure Machine Learning` entry.

1. Get the object ID of the `Azure Machine Learning` service principal.

Azure CLI:

```Bash
    az ad sp list --display-name "Azure Machine Learning" --query '[].[appDisplayName,objectId]' --output tsv
```

PowerShell:

```powershell
    Get-AzADServicePrincipal --DisplayName "Azure Machine Learning" | select-object DisplayName, Id
```

1. To add the service principal as a contributor to your subscription, use one of the following commands. Replace the `<subscription-ID>` with your subscription ID and `<object-ID>` with the ID for the service principal:

Azure CLI:

```Bash
    az role assignment create --role 'Contributor' --assignee-object-id <object-ID> --subscription <subscription-ID>
```

PowerShell:

```powershell
    New-AzRoleAssignment --ObjectId <object-ID> --RoleDefinitionName "Contributor" -Scope /subscriptions/<subscription-ID>
```

### Add a key for encryption

To generate a key in an existing Azure Key Vault, you can use the [prereq template](prereqs/prereq.azuredeploy.json) or complete the steps manually in the Azure Portal.

### Enable customer-managed keys for Azure Cosmos DB

See data encryption section of [Enterprise Security for Azure Machine Learning](https://docs.microsoft.com/azure/machine-learning/concept-enterprise-security#data-encryption) and [Configure customer-managed keys for your AzureCosmos account](https://docs.microsoft.com/azure/cosmos-db/how-to-setup-cmk).

### Add an access policy to the key vault

To add an access policy for Azure Cosmos DB to the key vault, use the following steps:

1. Get the object ID of the `Azure Cosmos DB` service principal, and save the ID for the `Azure Cosmos DB` entry.

Azure CLI

```Bash
    az ad sp list --display-name "Azure Cosmos DB" --query '[].[appDisplayName,objectId]' --output tsv
```

PowerShell

```powershell
    Get-AzADServicePrincipal --DisplayName "Azure Cosmos DB" | select-object DisplayName, Id
```

1. To set the policy, use the following command. Replace `<keyvault-name>` with the name of the key vault. Replace `<object-ID>` with the ID for the service principal:

Azure CLI:

```bash
    az keyvault set-policy --name <keyvault-name> --object-id <object-ID> --key-permissions get unwrapKey wrapKey
```

PowerShell:

```powershell
    Set-AzKeyVaultAccessPolicy -VaultName <keyvault-name> -ObjectId <object-ID> -PermissionsToKeys get, unwrapKey, wrapKey
```

### Look up cmk_keyvault and cmk_keyvault_key_uri

Use the below command to find the required value for the `cmk_keyvault` template parameter.The value is an Azure Resource Manager resource id of the following format: `/subscriptions/<subscripiton id>/resourceGroup/<rg name>/providers/Microsoft.KeyVault/vaults/<keyvault-name>`.

Azure CLI:

```bash
    az keyvault show --name <keyvault-name>
```

PowerShell: 

```powershell
    Get-AzKeyVault -VaultName '<keyvault-name>'
``` 

Use the below command to find the required value for the `cmk_keyvault_key_uri` template parameter. The property `kid` represents the cmk_keyvault_key_uri, and has the following resource naming: `https://<keyvault-name>.vault.azure.net/keys/<key-name>/<key-version>`.

```bash
    az keyvault key show --vault-name <keyvault-name> --name <key-name> 
```

PowerShell:

```powershell
    Get-AzureKeyVaultKey -VaultName '<keyvault-name>' -KeyName '<key-name>'
```

Use these parameters as input to the workspace deployment template.

## Learn more

If you are new to Azure Machine Learning, see:

- [Azure Machine Learning service](https://azure.microsoft.com/services/machine-learning-service/)
- [Azure Machine Learning documentation](https://docs.microsoft.com/azure/machine-learning/)
- [Enterprise security and governance for Azure Machine Learning](https://docs.microsoft.com/en-us/azure/machine-learning/concept-enterprise-security).
- [Azure Machine Learning template reference](https://docs.microsoft.com/azure/templates/microsoft.machinelearningservices/allversions)

To learn about encryption with Azure Machine Learning, see:

* [Encryption at rest](https://docs.microsoft.com/azure/machine-learning/concept-enterprise-security#data-encryption)
* [Configure customer-managed keys for Azure Cosmos](https://docs.microsoft.com/azure/cosmos-db/how-to-setup-cmk).

If you are new to template development, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
- [Use an Azure Resource Manager template to create a workspace for Azure Machine Learning](https://docs.microsoft.com/azure/machine-learning/service/how-to-create-workspace-template)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/)
