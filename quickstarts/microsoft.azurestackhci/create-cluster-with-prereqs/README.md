---
description: This template creates an Azure Stack HCI 23H2 cluster using a Bicep template.
page_type: sample
products:
- azure
- Bicep
urlFragment: create-cluster-with-prereqs
languages:
- json
---
# Creates an Azure Stack HCI 23H2 cluster and supporting resources

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster-with-prereqs/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster-with-prereqs/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster-with-prereqs/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster-with-prereqs/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster-with-prereqs/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster-with-prereqs/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster-with-prereqs/BicepVersion.svg)

This template allows you to create an Azure Stack HCI cluster 23H2+ cluster and all of the supporting resources including:

- Key Vault - which will be named *deploymentprefix*-hcikv
- Key Vault Diagnostic Storage Account - which will be named *deploymentprefix*diag
- Cloud Witness Storage Account - which will be named *deploymentprefix*witness
- Custom Location - which will be named *deploymentprefix*_cl 

The deployment includes three network intents, one each for management, compute, and storage--one of the more common configurations.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster-with-prereqs%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster-with-prereqs%2Fazuredeploy.json)

## Prerequisites

In order to deploy this template, you must have completed the following steps:

1. Arc enabled the server(s) and installed the mandatory extensions using the `invoke-AzStackHciArcInitialization` PowerShell command. 
1. Prepared an Active Directory with the PowerShell `New-HciAdObjectsPreCreation` command to create a dedicated Organizational Unit and Deployment User
1. Create a Service Principal for the Arc Resource Bridge. This identity needs "Azure Resource Bridge Deployment Role" permissions on the target subscription to deploy the Resource Bridge. Use the Application ID as arbDeploymentAppId and a client secret for the arbDeploymentServicePrincipalSecret parameters.
1. The user executing the Bicep or ARM deployment also needs "Contributor" and "User Access Admin" permission at resource group level

To determine the Microsoft.AzureStackHCI Resource Provider's Service Principal ID for parameter `hciResourceProviderObjectId` in your tenant, run `Get-AzADServicePrincipal -ApplicationId 1412d89f-b8a8-4111-b4fd-e82905cbd85d` after having registered the resource provider with `Register-AzResourceProvider Microsoft.AzureStackHCI`.

All additional required permissions are assigned during the deployment, including:

- Key Vault Secret User to each of the Managed Identities of the nodes, at the Key Vault resource level
- Connected MachineResource Manager to each of the Managed Identities of the nodes, and the Microsoft.AzureStackHCI Resource Provider, at the resource group level
- Azure Stack HCI Device Management Role to each of the Managed Identities of the nodes, at the resource group level
- Reader to each of the Managed Identities of the nodes, at the resource group level

> [!NOTE]
> The Key Vault secrets are encoded using base64 as part of the deployment
> 
> Within [azuredeploy.parameters.json](.\azuredeploy.parameters.json) the storageNetworks parameter needs to include an array of at least two storage network object with both an adapterName and vlan property: e.g
> 
> ```json
> "storageAdapters": {
>    "value":[
>      {"adapterName":"smb1","vlan":"711"},
>      {"adapterName":"smb2","vlan":"712"}
>      ]}
>```

## Deployment

When deploying Azure Stack HCI clusters using a Bicep or ARM template, the deployment goes through a validate phase followed by a deployment phase. For example, when using this template with a parameter file which has been updated to reflect your environment, the two phase deployment could look like this:

### Validation Phase

```azurecli
az deployment group create -g rg-myhcicluster -f .\main.bicep -p .\azuredeploy.parameters.contoso.json
```

### Deployment Phase

Change the `deploymentMode` parameter to `Deploy` by appending `-p deploymentMode=Deploy` to the deployment command. Once the deployment has started, you can follow the progress in the Portal or by reviewing the C:\CloudDeployment\Logs\CloudDeployment*.log file on the first cluster node.

```azurecli
az deployment group create -g rg-myhcicluster -f .\main.bicep -p .\azuredeploy.parameters.contoso.json -p deploymentMode=Deploy
```

`Tags: Microsoft.AzureStackHCI/clusters, hci`