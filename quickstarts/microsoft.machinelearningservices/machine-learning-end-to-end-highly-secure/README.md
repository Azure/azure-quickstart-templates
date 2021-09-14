# Azure Machine Learning end-to-end setup (highly secure configuration)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-end-to-end-highly-secure/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-end-to-end-highly-secure/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-end-to-end-highly-secure/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-end-to-end-highly-secure/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-end-to-end-highly-secure/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-end-to-end-highly-secure/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Fmachine-learning-end-to-end-highly-secure%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Fmachine-learning-end-to-end-highly-secure%2Fazuredeploy.json)

This deployment configuration specifies an [Azure Machine Learning workspace](https://docs.microsoft.com/en-us/azure/machine-learning/concept-workspace), 
and its associated resources including Azure Key Vault, Azure Storage, Azure Application Insights and Azure Container Registry.

In addition to these core services, this configuration specifies any networking components that are required to set up Azure Machine Learning
for private network connectivity using [Azure Private Link](https://docs.microsoft.com/en-us/azure/private-link/). 

This configuration describes the minimal set of resources you require to get started with Azure Machine Learning in a network-isolated set-up.

## Resources

| Provider and type | Description |
| - | - |
| `Microsoft.Resources/resourceGroups` | The resource group all resources get deployed into |
| `Microsoft.Insights/components` | An Azure Application Insights instance associated to the Azure Machine Learning workspace |
| `Microsoft.KeyVault/vaults` | An Azure Key Vault instance associated to the Azure Machine Learning workspace |
| `Microsoft.Storage/storageAccounts` | An Azure Storage instance associated to the Azure Machine Learning workspace |
| `Microsoft.ContainerRegistry/registries` | An Azure Container Registry instance associated to the Azure Machine Learning workspace |
| `Microsoft.MachineLearningServices/workspaces` | An Azure Machine Learning workspace instance |
| `Microsoft.Network/virtualNetworks` | An Azure Machine Learning workspace instance |
| `Microsoft.Network/virtualNetworks/subnets` | An Azure Machine Learning workspace instance |
| `Microsoft.Network/privateDnsZones` | Private DNS Zones for FQDNs required for Azure Machine Learning and associated resources |
| `Microsoft.Network/privateDnsZones/virtualNetworkLinks` | Virtual network links of the Private DNS Zones to the virtual network resource |
| `Microsoft.Network/privateEndpoints` | Private Endpoints for the Azure Machine Learning workspace and associated resources |

## Variables

| Name | Description |
|-|-|
| name | Name of the deployment |
| environment | The deployment environment name (used for pre- and postfixing resource names) |
| location | The Azure region used for deployments |

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
