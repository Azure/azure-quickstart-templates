# Azure App Configuration

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-store-kv-copy/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-store-kv-copy/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-store-kv-copy/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-store-kv-copy/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-store-kv-copy/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-store-kv-copy/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.appconfiguration%2Fapp-configuration-store-kv-copy%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.appconfiguration%2Fapp-configuration-store-kv-copy%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.appconfiguration%2Fapp-configuration-store-kv-copy%2Fazuredeploy.json)

This template creates an Azure App Configuration store, then creates two key-values inside the new store via a copy function. This can also deploy key-values that link to an Azure Key Vault.

## Parameters

### configStoreName
- type: string
- description: Specifies the name of the App Configuration store.
- required: true

### location
- type: string
- description: Specifies the Azure location where the app configuration store should be created.
- required: false

### keyData
- type: array
- description: Array of Objects that contain the key name, key value, label(s), tag(s) and contentType
- required: true
- breakdown:
  - key: Name of the Key to be added to the App Configuration Store
    - type: string
    - required: true
  - value: Value of the Key to be added to the App Configuration Store
    - type: string
    - required: false
  - label: Label of of the Key to be added to the App Configuration Store. If multiple labels are wanted then an additional entry to the array is added.
    - type: string
    - required: false
  - tag: Object containing the tag(s) of the Key to be added to the App Configuration Store.
    - type: object
    - required: false
  - contentType: Content Type of the Key to be added to the App Configuration Store.
    - type: string
    - required: false

### Notes

- Key Value Secret Key Entry
  - keyData.key: This can be what you want it to be.
  - keyData.value: Format should be https://{vault-name}.{vault-DNS-suffix}/secrets/{secret-name}/{secret-version}. Secret version is optional.
  - keyData.contentType: Must be 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'.

## Reference Documentation

If you're new to App Configuration, see:

- [Azure App Configuration](https://azure.microsoft.com/services/app-configuration/)
- [Azure App Configuration documentation](https://docs.microsoft.com/azure/azure-app-configuration/)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.appconfiguration/allversions)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
- [Quickstart: Create an Azure App Configuration store by using an ARM template](https://docs.microsoft.com/azure/azure-app-configuration/quickstart-resource-manager)

`Tags: Azure4Student, AppConfiguration, Beginner`
