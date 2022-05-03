# Azure Web Application Firewall v2 on Application Gateway Quickstart

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-docs-wafv2/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-docs-wafv2/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-docs-wafv2/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-docs-wafv2/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-docs-wafv2/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-docs-wafv2/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fag-docs-wafv2%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fag-docs-wafv2%2Fazuredeploy.json)

This template deploys an **Web Application Firewall** v2 on Azure Application Gateway. The WAF has a policy with a simple custom rule that blocks traffic to the two virtual machine backend pool. The custom rule can then be modified to allow traffic to the backend pool.

The backend virtual machines are *Standard_B2ms* virtual machines running Windows Server 2019 with IIS installed to test the application gateway functionality.

## Deployment steps

You can select **Deploy to Azure** at the top of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Notes

This template is used by the Web Application Firewall documentation [quickstart](https://docs.microsoft.com/azure/web-application-firewall/ag/quick-create-template) article.

`Tags: Web Application Firewall`
