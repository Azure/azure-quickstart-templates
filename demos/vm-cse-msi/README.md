# Virtual Machine Custom Script Using a Managed Identity for Artifacts

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-cse-msi/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-cse-msi/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-cse-msi/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-cse-msi/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-cse-msi/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-cse-msi/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-cse-msi%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-cse-msi%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvm-cse-msi%2Fazuredeploy.json)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vm-cse-msi/BicepVersion.svg)

This template shows how to download artifacts for the Virtual Machine's custom script extension using a user assigned managed identity.  This approach does not require the use of a sasToken or public access to download the artifacts.

The typical pattern in this repo (for all artifacts) is to stage and create a sasToken during deployment.  This sample expects that the artifacts are staged before deployment and the managed identity must have ```Storage Blob Data Reader``` access to the storageAccount.  Staging and access to the artifacts is distinct from the deployment of the template.

Note that the managed identity must be assigned to the VM as well as specified on the extension resource in ```protectedSettings```.

The output of the deployment shows a directory listing of the downloaded files.

For more information on this approach see [Custom Script Extension for Windows](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows#property-managedidentity).
