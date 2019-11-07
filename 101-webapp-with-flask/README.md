# Deploy a Flask app

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-flask-app-service/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-flask-app-service/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-flask-app-service/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-flask-app-service/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-flask-app-service/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-flask-app-service/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure4StudentQSTemplates%2Fazure-quickstart-templates%2Fmaster%2F101-flask-app-service%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure4StudentQSTemplates%2Fazure-quickstart-templates%2Fmaster%2F101-flask-app-service%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template allows you to deploy your Flask app using App Service. This will deploy a Free App Service in a Resource Group that we should create before launch our template.

# This button is only for test one-button deployment

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjose-mart%2Ftemplates%2Fmaster%2F101-flask-app-service%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>

## Parameters

|**PARAMETERS NAME**   |**DESCRIPTION**   |
|---|---|
|name   |Name for your application. It has to be unique.   |
|location   |Location for the deploy of our resources.   |

## Variables

|**VARIABLES NAME**   |**DESCRIPTION**   |
|---|---|
|alwaysOn   |It allows us to have the app On even if it is no traffic.   |
|sku   |Shape for our product.   |
|skuCode   |Code to identify our product.   |
|workerSize   |Optional. The worker size. Possible values are Small, Medium, and Large. For JSON, the equivalents are 0 = Small, 1 = Medium, and 2 = Large   |
|workerSizeId   |Gets or sets size ID of machines: 0 - Small 1 - Medium 2 - Large   |
|numberOfWorkers   |Gets or sets number of workers.   |
|linuxFxVersion   |The Linux APP Framework and version.   |
|hostingPlanName   |Name for the hosting plan. On free tier, you can only have 1 Linux hosting environment in your subscription.   |

## Use the template

App Service Free Tier let you to get only 1 Linux web host (App Service Plan) deployed. Each free app service plan can host 10 apps. 

So, here we have different options:

**Option 1**
If you have already a web app deployed, instead of using the template, use Azure CLI and use the command "az web app up" like we used on the [GettingStarted](https://github.com/Azure4StudentQSTemplates/azure-quickstart-templates/blob/master/101-flask-app-service/GettingStarted.md).

**Option 2**
If you haven't a web app deployed, you can use the template perfectly. 

### PowerShell

```
New-AzResourceGroup -Name <resource-group-name> -Location <resource-group-location> #use this command when you need to create a new resource group for your deployment
New-AzResourceGroupDeployment -ResourceGroupName <resource-group-name> -TemplateUri 
```

[Install and configure Azure PowerShell](https://docs.microsoft.com/es-es/powershell/azure/?view=azps-2.8.0)

### Command line

```
az group create --name <resource-group-name> --location <resource-group-location> #use this command when you need to create a new resource group for your deployment
az group deployment create --resource-group <my-resource-group> --template-uri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-flask-app-service/azuredeploy.json
```

[Install and configure the Azure Cross-Platform Command-Line Interface](https://docs.microsoft.com/es-es/cli/azure/install-azure-cli?view=azure-cli-latest)
