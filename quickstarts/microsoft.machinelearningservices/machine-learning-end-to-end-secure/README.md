# Azure Machine Learning workspace

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-end-to-end-secure/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-end-to-end-secure/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-end-to-end-secure/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-end-to-end-secure/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-end-to-end-secure/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-end-to-end-secure/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-end-to-end-secure/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Fmachine-learning-end-to-end-secure%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Fmachine-learning-end-to-end-secure%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Fmachine-learning-end-to-end-secure%2Fazuredeploy.json)   

This set of Bicep templates demonstrates how to set up Azure Machine Learning end-to-end in a secure set up.

This reference implementation includes the Workspace, a CPU compute cluster, a GPU compute cluster, compute instance and attached private AKS cluster. It  includes the configuration of associated resources including Azure Key Vault, Azure Storage, Azure Application Insights and Azure Container Registry in a network-isolated setup.

## Resources

| Provider and type | Description |
| - | - |
| `Microsoft.Resources/resourceGroups` | The resource group all resources get deployed into |
| `Microsoft.Insights/components` | An Azure Application Insights instance associated to the Azure Machine Learning workspace |
| `Microsoft.KeyVault/vaults` | An Azure Key Vault instance associated to the Azure Machine Learning workspace |
| `Microsoft.Storage/storageAccounts` | An Azure Storage instance associated to the Azure Machine Learning workspace |
| `Microsoft.ContainerRegistry/registries` | An Azure Container Registry instance associated to the Azure Machine Learning workspace |
| `Microsoft.MachineLearningServices/workspaces` | An Azure Machine Learning workspace instance |
| `Microsoft.MachineLearningServices workspaces/computes` | Azure Machine Learning workspace compute types: cluster and compute instance |
| `Microsoft.Network/privateDnsZones` | Private DNS zones for Azure Machine Learning and the dependent resources |
| `Microsoft.Network/networkSecurityGroups` | A Network Security Group pre-configured for use with Azure Machine Learning |
| `Microsoft.ContainerService/managedClusters` | An Azure Kubernetes Services cluster for inferencing |
| `Microsoft.Compute/virtualMachines` | A Data Science Virtual Machine `jumpbox` to access the workspace over the private link endpoint |
| `Microsoft.Network/virtualNetworks` | A virtual network to deploy all resources in |

## Variables

| Name | Description | Default |
|-|-|-|
| location | Specifies the Azure region for all resources | resourceGroup().location |
| prefix | Specifies the prefix for all resources created in this deployment | - |
| tags | Any tags you want to apply to all resources | {} |
| vnetAddressPrefix | Specifies the address prefix of the virtual network. | '192.168.0.0/16' |
| trainingSubnetPrefix | Specifies the address prefix of the training subnet. | '192.168.0.0/24' |
| scoringSubnetPrefix | Specifies the address prefix of the scoring subnet. | '192.168.1.0/24' |
| azureBastionSubnetPrefix | Specifies the address prefix of the azure bastion subnet. | '192.168.250.0/27' |
| dsvmJumpboxUsername | Admin username for the Data Science Virtual Machine (jumpbox) | - |
| dsvmJumpboxPassword | Admin password for the Data Science Virtual Machine (jumpbox) | - |

## Usage

First, create an Azure resource group:
`az group create --name <resource-group-name> --location <location>`

Then deploy the 'main' Bicep template file:
`az deployment group create --resource-group <resource-group-name> --template-file .\main.bicep`

After succesful deployment, log on to the Data Science Virtual Machine Jumpbox machine that you just deployed to access your workspace from the virtual network. To learn more, see [Securely connect to your workspace](https://docs.microsoft.com/en-us/azure/machine-learning/how-to-secure-workspace-vnet?tabs=pe#securely-connect-to-your-workspace).

Optionally, you could build an Azure Resource Manager template after making changes to your Bicep file:
`az bicep build --file .\main.bicep --outfile .\azuredeploy.json`

## Learn more

If you are new to Azure Machine Learning, see:

- [Azure Machine Learning service](https://azure.microsoft.com/services/machine-learning-service/)
- [Azure Machine Learning documentation](https://docs.microsoft.com/azure/machine-learning/)
- [Enterprise security and governance for Azure Machine Learning](https://docs.microsoft.com/en-us/azure/machine-learning/concept-enterprise-security).
- [Azure Machine Learning template reference](https://docs.microsoft.com/azure/templates/microsoft.machinelearningservices/allversions)

If you are new to template development, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
- [Use an Azure Resource Manager template to create a workspace for Azure Machine Learning](https://docs.microsoft.com/azure/machine-learning/service/how-to-create-workspace-template)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/)
