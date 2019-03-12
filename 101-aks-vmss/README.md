# Azure Kubernetes Service (AKS) with autoscaling (VMSS) - PREVIEW

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAdamSharif-MSFT%2Fazure-quickstart-templates%2Fmaster%2F101-aks-vmss%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAdamSharif-MSFT%2Fazure-quickstart-templates%2Fmaster%2F101-aks-vmss%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys a simple **AKS cluster** with autoscaling using Virtual Machine Scale Sets (VMSS).

See https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler for more information.

**Please note that this is a preview feature. Previews are made available to you on the condition that you agree to the supplemental terms of use. Some aspects of this feature may change prior to general availability (GA). For more information, please refer to https://azure.microsoft.com/support/legal/preview-supplemental-terms/**

Please note that before using this template you will need to register the following features and providers:

```
az feature register --name VMSSPreview --namespace Microsoft.ContainerService
```

```
az provider register -n Microsoft.ContainerService
```

To use keys stored in keyvault, replace ```"value":""``` with a reference to keyvault in parameters file. For example:

```json
"servicePrincipalClientSecret": {
      "reference": {
        "keyVault": {
          "id": "<specify Resource ID of the Key Vault you are using>"
        },
        "secretName": "<specify name of the secret in the Key Vault to get the service principal password from>"
      }
    }
```

## Prerequisites

Prior to deploying AKS using this ARM template, the following resources need to exist:
- Service Principal

The following Azure CLI command can be used to create a Service Principal:

_NOTE:  The Service Principal Client Id is the Same as the App Id_

```shell
az ad sp create-for-rbac -n "spn_name" --skip-assignment
az ad sp show --id <The AppId from the create-for-rbac command> --query objectId
```

Please note that using the 'create-for-rbac' function would assign the SPN the 'Contributor' role on subscription level, which may not be appropriate from a security standpoint.

## Credits

This script is based on the following templates:

https://github.com/azure/azure-quickstart-templates/tree/master/101-aks-advanced-networking
https://github.com/azure/azure-quickstart-templates/tree/master/101-aks
