# Deploy a ASP.NET app service

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-asp-net-app-service%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-asp-net-app-service%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template allows you to deploy your own ASP.NET app using App Service. This will deploy a Free App Service in a Resource Group that we should create before launch our template.

## Parameters

|**PARAMETERS NAME**   |**DESCRIPTION**   |
|---|---|
|name   |Name for your application.   |
|location   |Location for the deploy of our resources.   |


## Variables

|**VARIABLES NAME**   |**DESCRIPTION**   |
|---|---|
|subscriptionId   |ID of our subscription   |
|hostingEnvironment   |Name of the App Service Environment. If you don't know if you need it, you should leave it empty. Here you can see some [documentation](https://docs.microsoft.com/en-in/azure/app-service/environment/intro)   |
|serverFarmResourceGroup   |Name of the resource group where our serverFarm is.   |
|alwaysOn   |It allows us to have the app On even if it is no traffic.   |
|sku   |Shape for our product.   |
|skuCode   |Code to identify our product.   |
|workerSize   |Optional. The worker size. Possible values are Small, Medium, and Large. For JSON, the equivalents are 0 = Small, 1 = Medium, and 2 = Large   |
|workerSizeId   |Gets or sets size ID of machines: 0 - Small 1 - Medium 2 - Large   |
|numberOfWorkers   |Gets or sets number of workers.   |
|currentStack   |Platform for our deploy..   |
|netFrameworkVersion   |Version of our .NET framework   |
|hostingPlanName   |Name for the hosting plan.   |

## Use the template

### PowerShell

```
New-AzResourceGroup -Name <resource-group-name> -Location <resource-group-location> #use this command when you need to create a new resource group for your deployment
New-AzResourceGroupDeployment -ResourceGroupName <resource-group-name> -TemplateUri 
```

[Install and configure Azure PowerShell]()

### Command line

```
az group create --name <resource-group-name> --location <resource-group-location> #use this command when you need to create a new resource group for your deployment
az group deployment create --resource-group <my-resource-group> --template-uri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-asp-net-app-service/azuredeploy.json
```

After a couple of minutes, we will have our Node app ready.


[Install and configure the Azure Cross-Platform Command-Line Interface]()