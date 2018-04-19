# Azure Container Service (AKS)

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