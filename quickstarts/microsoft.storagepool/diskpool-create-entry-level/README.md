# Deploy an entry level Disk Pool

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storagepool/diskpool-create-entry-level/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storagepool/diskpool-create-entry-level/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storagepool/diskpool-create-entry-level/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storagepool/diskpool-create-entry-level/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storagepool/diskpool-create-entry-level/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storagepool/diskpool-create-entry-level/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.storagepool%2Fdiskpool-create-entry-level%2Fazuredeploy.json)  
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.storagepool%2Fdiskpool-create-entry-level%2Fazuredeploy.json)

This template deploys a Disk Pool with a 1TB Premium Disk into an existing subnet.

This template also assigns the Disk Pool Operator Role to the deployed disk.

**Use following powershell command to get Principal ID associated with a tenant. The ID is the principal ID.

PS C:\> Get-AzADServicePrincipal -DisplayName "StoragePool Resource Provider"

PARAMETER RESTRICTIONS
======================

The VNet and subnet needs to be previously created and the subnet needs to be delegated to Microsoft.StoragePool/diskPools.
diskPoolName must be 7-30 characters in length.
targetName must be 5-40 characters in length; supported characters include [0-9a-z-.]; and the name should end with an alphanumeric character.