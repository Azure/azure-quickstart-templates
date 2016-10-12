# Confgure Git Deployment to VMSS 


## Note
Since we're deploying a private key to the VM, we'd deploy those directly from Azure Key Vault in a production setting.

To do this you'd store the private key as a secret in Azure Key Vault and point the parameter to the key vault secret:

The parameter definition in the ARM template would like this:
```
    "gitSshPrivateKey": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/[subscriptionId]/resourceGroups/[rgName]/providers/Microsoft.KeyVault/vaults/[keyVaultName]"
        },
        "secretName": "[secretName]"
      }
    }
```
 instead of this:

 ```
     "gitSshPrivateKey": {
      "type": "string",
      "metadata": {
        "description": "SSH Private Key to authenticate against the git repo"
      }
    }
  ```

