# Azure Application Gateway v2 Quickstart

    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ag-docs-qs/PublicLastTestDate.svg" />&nbsp;
    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ag-docs-qs/PublicDeployment.svg" />&nbsp;

    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ag-docs-qs/FairfaxLastTestDate.svg" />&nbsp;
    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ag-docs-qs/FairfaxDeployment.svg" />&nbsp;
    
    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ag-docs-qs/BestPracticeResult.svg" />&nbsp;
    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ag-docs-qs/CredScanResult.svg" />&nbsp;
    
    
    <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fag-docs-qs%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>
    </a>
    <a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fag-docs-qs%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"/>
    </a>

This template deploys an **Azure Application Gateway** v2. The application gateway uses a simple setup with a public front-end IP, a basic listener to host a single site on the application gateway, a basic request routing rule, and two virtual machines in the backend pool.

The backend servers are "Standard_B2ms" virtual machines running Windows Server 2016 with IIS installed to test the application gateway functionality.

## Deployment steps

You can select **Deploy to Azure** at the top of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Notes

This template is used by the Azure Application Gateway documentation Quick Start article.

`Tags: Application Gateway`