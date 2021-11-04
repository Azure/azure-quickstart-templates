# Deploy an entry level Disk Pool

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storagepool/diskpool-create-entry-level/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storagepool/diskpool-create-entry-level/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storagepool/diskpool-create-entry-level/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storagepool/diskpool-create-entry-level/FairfaxDeployment.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storagepool/diskpool-create-entry-level/BicepVersion.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storagepool/diskpool-create-entry-level/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storagepool/diskpool-create-entry-level/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.storagepool%2Fdiskpool-create-entry-level%2Fazuredeploy.json) 
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.storagepool%2Fdiskpool-create-entry-level%2Fazuredeploy.json)

This template deploys a Disk Pool with an existing 1TB Premium Disk into an existing subnet.

This template needs the following pre-requisites:
- A virtual network and subnet in the same location as the Disk Pool. The subnet needs to be delegated to "Microsoft.StoragePool/diskPools".
- 1 1TB Premium disk in the same location as the Disk Pool.
- "Disk Pool Operator" role assignment with the "StoragePool Resource Provider" role on the disk.

**Use following powershell command to get Principal ID associated with a tenant. The ID is the principal ID.

```powershell
PS C:\> Get-AzADServicePrincipal -DisplayName "StoragePool Resource Provider"
```
