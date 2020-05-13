# Azure Container Service (AKS)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-aks/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-aks/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-aks/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-aks/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-aks/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-aks/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-aks%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-aks%2Fazuredeploy.json)



This template deploys an **AKS cluster**.

See https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough for a walkthrough.

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
