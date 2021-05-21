# Retrieve Azure Storage access keys in ARM template

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/arm-template-retrieve-azure-storage-access-keys/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/arm-template-retrieve-azure-storage-access-keys/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/arm-template-retrieve-azure-storage-access-keys/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/arm-template-retrieve-azure-storage-access-keys/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/arm-template-retrieve-azure-storage-access-keys/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/arm-template-retrieve-azure-storage-access-keys/CredScanResult.svg)

This template will create a Storage account, after which it will create a API connection by dynamically retrieving the primary key of the Storage account. The API connection is then used in a Logic App as a trigger polling for blob changes. The complete scenario can be found on <https://blog.eldert.net/retrieve-azure-storage-access-keys-in-arm-template>.

Tags: arm, storage, security

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Farm-template-retrieve-azure-storage-access-keys%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Farm-template-retrieve-azure-storage-access-keys%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Farm-template-retrieve-azure-storage-access-keys%2Fazuredeploy.json)



