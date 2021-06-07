# Azure Application Gateway v2 Quickstart

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-docs-qs/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-docs-qs/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-docs-qs/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-docs-qs/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-docs-qs/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-docs-qs/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fag-docs-qs%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fag-docs-qs%2Fazuredeploy.json)

This template deploys an **Azure Application Gateway** v2. The application gateway uses a simple setup with a public front-end IP, a basic listener to host a single site on the application gateway, a basic request routing rule, and two virtual machines in the backend pool.

The backend servers are **Standard_B2ms** virtual machines running Windows Server 2016 with IIS installed to test the application gateway functionality.

## Deployment steps

You can select **Deploy to Azure** at the top of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Notes

This template is used by the Azure Application Gateway documentation [quickstart article](https://docs.microsoft.com/azure/application-gateway/quick-create-template).

`Tags: Application Gateway`
