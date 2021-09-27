# Azure Machine Learning workspace (secure network configuration)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-workspace-vnet/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-workspace-vnet/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-workspace-vnet/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-workspace-vnet/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-workspace-vnet/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/machine-learning-workspace-vnet/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Fmachine-learning-workspace-vnet%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Fmachine-learning-workspace-vnet%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Fmachine-learning-workspace-vnet%2Fazuredeploy.json)

This template is an advanced Azure Machine Learning workspace creation templates which support:

- Create workspace with existing dependent resources like storage account, application insights, key vault or container registry.
- Create workspace with auto-approval or manual approval private endpoint, both new VNET and existing vnet is supported.
- Create workspace with customer managed key.
- Create workspace with link to Azure Databricks workspace.
- Create workspace with dependent resources(new resources only) behind virtual network.
- Create workspace with user assigned identity.

## Supported Scenarios

The following commands show the advanced scenarios for workspace creation.

### Create machine learning workspace with existing dependent resources

This command creates a workspace with private endpoint.

```PowerShell
# For deployment with existing resources, use "existing" for the option and resource group name is required.

# Create a workspace with existing storage account, key vault and appinsights
New-AzResourceGroupDeployment -ResourceGroupName "rg" -TemplateFile ".\azuredeploy.json" -workspaceName "workspaceName" -location "westus2" -Name "deploymentname" -storageAccountOption "existing" -storageAccountResourceGroupName "existing-storage-rg" -storageAccountName "existing-storage-name" -keyVaultOption "existing" -keyVaultResourceGroupName "existing-kv-rg" -keyVaultName "existing-kv-name" -applicationInsightsOption "existing" -applicationInsightsResourceGroupName "existing-ai-rg" -applicationInsightsName "existing-ai-name" -identityType "systemAssigned"
```

### Create machine learning workspace with private endpoint

This command creates a workspace with private endpoint.

```PowerShell
# The deployment is only valid in regions which support private endpoints. For manual approval private endpoint, just set privateEndpointType="ManualApproval"

# Create a workspace with private endpoint
New-AzResourceGroupDeployment -ResourceGroupName "rg" -TemplateFile ".\azuredeploy.json" -workspaceName "workspaceName" -location "westus2" -Name "deploymentname" -privateEndpointType "AutoApproval"

# Create a workspace with private endpoint with user specified virtual network name
New-AzResourceGroupDeployment -ResourceGroupName "rg" -TemplateFile ".\azuredeploy.json" -workspaceName "workspaceName" -location "westus2" -Name "deploymentname" -privateEndpointType "AutoApproval" -vnetName "vnet" -subnetName "subnet"

# Create a workspace with private endpoint with user specified existing vnet
New-AzResourceGroupDeployment -ResourceGroupName "rg" -TemplateFile ".\azuredeploy.json" -workspaceName "workspaceName" -location "westus2" -Name "deploymentname" -privateEndpointType "AutoApproval" -vnetName "vnet" -vnetOption "existing" -vnetResourceGroupName "rg" -subnetName "subnet" -subnetOption "existing"
```

### Create machine learning workspace with resources behind virtual network

This command is an example of creating workspace with resource behind vnet.

```PowerShell
# Parameter 'vnetOption' is required for this scenario and should not be 'none'. The example shows how to put the storage account behind vnet. You can also apply the scenario into key vault and container registry. For container registry, only 'Premium' sku is supported.

# Create a workspace with storage account behind a new vnet.
New-AzResourceGroupDeployment -ResourceGroupName "rg" -TemplateFile ".\azuredeploy.json" -workspaceName "workspaceName" -location "westus2" -Name "deploymentname" -storageAccountBehindVNet "true" -vnetOption "new" -vnetName "vnet"

# Create a workspace with storage account behind an existing vnet and an existing subnet.
# Prerequisite: Subnet should have Microsoft.Storage service endpoint
# Enable service endpoint
Get-AzVirtualNetwork -ResourceGroupName "rg" -Name "vnet" | Set-AzVirtualNetworkSubnetConfig -Name "subnet" -AddressPrefix "<subnet prefix>" -ServiceEndpoint "Microsoft.Storage" | Set-AzVirtualNetwork
# Deployment
New-AzResourceGroupDeployment -ResourceGroupName "rg" -TemplateFile ".\azuredeploy.json" -workspaceName "workspaceName" -location "westus2" -Name "deploymentname" -storageAccountBehindVNet "true" -vnetOption "existing" -vnetName "vnet" -vnetResourceGroupName "rg" -subnetName "subnet" -subnetOption "existing"

# Create a workspace with all dependent resources behind a new vnet
New-AzResourceGroupDeployment -ResourceGroupName "rg" -TemplateFile ".\azuredeploy.json" -workspaceName "workspaceName" -location "westus2" -Name "deploymentname" -containerRegistryOption "new" -containerRegistrySku "Premium" -storageAccountBehindVNet "true" -keyVaultBehindVNet "true" -containerRegistryBehindVNet "true" -vnetOption "new" -vnetName "vnet"

# Create a workspace with all dependent resources behind an existing vnet
# Service endpoints
Get-AzVirtualNetwork -ResourceGroupName "rg" -Name "vnet" | Set-AzVirtualNetworkSubnetConfig -Name "subnet" -AddressPrefix "<subnet prefix>" -ServiceEndpoint "Microsoft.Storage" | Set-AzVirtualNetwork
Get-AzVirtualNetwork -ResourceGroupName "rg" -Name "vnet" | Set-AzVirtualNetworkSubnetConfig -Name "subnet" -AddressPrefix "<subnet prefix>" -ServiceEndpoint "Microsoft.KeyVault" | Set-AzVirtualNetwork
Get-AzVirtualNetwork -ResourceGroupName "rg" -Name "vnet" | Set-AzVirtualNetworkSubnetConfig -Name "subnet" -AddressPrefix "<subnet prefix>" -ServiceEndpoint "Microsoft.ContainerRegistry" | Set-AzVirtualNetwork
# Deployment
New-AzResourceGroupDeployment -ResourceGroupName "rg" -TemplateFile ".\azuredeploy.json" -workspaceName "workspaceName" -location "westus2" -Name "deploymentname" -containerRegistryOption "new" -containerRegistrySku "Premium" -storageAccountBehindVNet "true" -keyVaultBehindVNet "true" -containerRegistryBehindVNet "true" -vnetOption "existing" -vnetName "vnet" -vnetResourceGroupName "rg" -subnetName "subnet" -subnetOption "existing"
```

### Create machine learning workspace with user assigned identity

This command is an example of creating workspace with user assigned identity.

```Powershell
New-AzResourceGroupDeployment -ResourceGroupName "rg" -TemplateFile ".\azuredeploy.json" -workspaceName "workspaceName" -location "westus2" -Name "deploymentname" -storageAccountOption "existing" -storageAccountResourceGroupName "existing-storage-rg" -storageAccountName "existing-storage-name" -keyVaultOption "existing" -keyVaultResourceGroupName "existing-kv-rg" -keyVaultName "existing-kv-name" -applicationInsightsOption "existing" -applicationInsightsResourceGroupName "existing-ai-rg" -applicationInsightsName "existing-ai-name" -identityType "userAssigned" -primaryUserAssignedIdentity "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai"
```


## Learn more

If you are new to Azure Machine Learning, see:

- [Azure Machine Learning service](https://azure.microsoft.com/services/machine-learning-service/)
- [Azure Machine Learning documentation](https://docs.microsoft.com/azure/machine-learning/)
- [Azure Machine Learning template reference](https://docs.microsoft.com/azure/templates/microsoft.machinelearningservices/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/)

If you are new to template development, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
- [Create an Azure Machine Learning service workspace by using a template](https://docs.microsoft.com/azure/machine-learning/service/how-to-create-workspace-template)
