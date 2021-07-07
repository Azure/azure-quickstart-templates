# Azure API Management Service

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-hostname/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-hostname/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-hostname/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-hostname/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-hostname/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-hostname/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-hostname%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-hostname%2Fazuredeploy.json)

This template shows an example of how to deploy an Azure API Management service with custom hostnames.  This also demonstrates how to configure multile proxy (gateway) custom hostnames for API Mangement service.  This template creates API Management service in Premium tier since the feature to configure multiple custom hostnames in proxy in API Management is only available in Premium tier of API Management.  However, you can configure single proxy custom hostname in any API Management tier.


