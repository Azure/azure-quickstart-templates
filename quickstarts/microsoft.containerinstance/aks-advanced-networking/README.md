# AKS with Advanced Networking

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aks-advanced-networking/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aks-advanced-networking/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aks-advanced-networking/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aks-advanced-networking/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aks-advanced-networking/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aks-advanced-networking/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerinstance%2Faks-advanced-networking%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerinstance%2Faks-advanced-networking%2Fazuredeploy.json)    

This ARM template demonstrates the deployment of an AKS instance with advanced networking features into an existing virtual network. Additionally, the selected Service Principal is assigned the Network Contributor role against the subnet that contains the AKS cluster.

`Tags: AKS, Kubernetes, Advanced Networking`

## Solution overview and deployed resources

Executing an AKS deployment using this ARM template will create an AKS instance. However, it will also assign the selected Service Principal the following roles:
- 'Network Contributor' role against the pre-existing subnet.
- 'Contributor' role against the automatically created resource group that contains the AKS cluster resources.

## Prerequisites

Prior to deploying AKS using this ARM template, the following resources need to exist:
- Azure Vnet, including a subnet of sufficient size
- Service Principal

The following Azure CLI command can be used to create a Service Principal:

_NOTE:  The Service Principal Client Id is the Same as the App Id_

```shell
az ad sp create-for-rbac -n "spn_name" --skip-assignment
az ad sp show --id <The AppId from the create-for-rbac command> --query objectId
```

Please note that using the 'create-for-rbac' function would assign the SPN the 'Contributor' role on subscription level, which may not be appropriate from a security standpoint.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the Azure documentation:
- [Deploy resources with Resource Manager templates and Azure PowerShell](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy)
- [Deploy resources with Resource Manager templates and Azure CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-cli)


