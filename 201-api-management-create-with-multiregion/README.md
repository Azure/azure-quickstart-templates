# Azure API Management Service

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-multiregion/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-multiregion/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-multiregion/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-multiregion/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-multiregion/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-multiregion/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-multiregion%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-multiregion%2Fazuredeploy.json)

This template demonstrates how to create API Management service with additional locations.  This template creates API Management service in Premium tier since the feature to deploy additional locations in API Management is only available in Premium tier of API Management. Make sure that the location is ResourceGroup is not same as location of one of additional Locations. The template deploys 3 units of Premium, consider the cost before deploying the template.


