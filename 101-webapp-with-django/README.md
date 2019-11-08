# Deploy a Django app

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-with-django/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-with-django/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-with-django/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-with-django/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-with-django/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-with-django/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-with-django%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-with-django%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template allows you to deploy your own Django app using App Service. This will deploy a Free App Service in a Resource Group that we should create before launch our template.

# Temporal button for test
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure4StudentQSTemplates%2Fazure-quickstart-templates%2Fjose-mart-test-webapp-with-django%2F101-webapp-with-django%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>

## Parameters

|**PARAMETERS NAME**   |**DESCRIPTION**   |
|---|---|
|webAppName   |Name for your application. It has to be unique.   |
|location   |Location for the deploy of our resources.   |

## Variables

|**VARIABLES NAME**   |**DESCRIPTION**   |
|---|---|
|sku   |Shape for our product.   |
|skuCode   |Code to identify our product.   |
|workerSize   |Optional. The worker size. Possible values are Small, Medium, and Large. For JSON, the equivalents are 0 = Small, 1 = Medium, and 2 = Large   |
|hostingPlanName   |Name for the hosting plan. On the free tier, you can only have 1 Linux hosting environment.   |
|appInsights  |Name for the application insights  |
