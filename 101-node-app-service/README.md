# Deploy a Node app

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-node-app-service%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-node-app-service%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template allows you to deploy your own Node app using App Service. This will deploy a Free App Service in a Resource Group that we should create before launch our template.

## Parameters

|**PARAMETERS NAME**   |**DESCRIPTION**   |
|---|---|
|name   |Name for your application. It has to be unique.   |


## Variables

|**VARIABLES NAME**   |**DESCRIPTION**   |
|---|---|
|subscriptionId   |ID of our subscription   |
|location   |Variable to retrieve the location from your Resource Group and apply for all other resources.   |
|hostingEnvironment   |Name of the App Service Environment. If you don't know if you need it, you should leave it empty. Here you can see some [documentation](https://docs.microsoft.com/en-in/azure/app-service/environment/intro)   |
|hostingPlanName   |Name for the hosting plan.   |
|serverFarmResourceGroup   |Name of the resource group where our serverFarm is.   |
|alwaysOn   |It allows us to have the app On even if it is no traffic.   |
|sku   |Shape for our product.   |
|skuCode   |Code to identify our product.   |
|workerSize   |Optional. The worker size. Possible values are Small, Medium, and Large. For JSON, the equivalents are 0 = Small, 1 = Medium, and 2 = Large   |
|workerSizeId   |Gets or sets size ID of machines: 0 - Small 1 - Medium 2 - Large   |
|numberOfWorkers   |Gets or sets number of workers.   |
|linuxFxVersion   |The Linux APP Framework and version.   |
|hostingPlanName   |Name for the hosting plan. On free tier, you can only have 1 linux hosting environment in your subscription.   |

## Use the template

App Service Free Tier let you to get only 1 linux web host (App Service Plan) deployed. Each free app service plan can host 10 apps. 

So, here we have differents options:

**Option 1**

If you have already a webapp deployed, instead of use the template, use Azure CLI and use the command "az webapp up" like we used on the [GettingStarted](https://github.com/Azure4StudentQSTemplates/azure-quickstart-templates/blob/master/101-node-app-service/GettingStarted.md).

**Option 2**

If you haven't a webapp deployed, you can use the template perfectly.  

### PowerShell

```
New-AzResourceGroup -Name <resource-group-name> -Location <resource-group-location> #use this command when you need to create a new resource group for your deployment
New-AzResourceGroupDeployment -ResourceGroupName <resource-group-name> -TemplateUri 
```

[Install and configure Azure PowerShell](https://docs.microsoft.com/es-es/powershell/azure/?view=azps-2.8.0)

### Command line

```
az group create --name <resource-group-name> --location <resource-group-location> #use this command when you need to create a new resource group for your deployment
az group deployment create --resource-group <my-resource-group> --template-uri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-node-app-service/azuredeploy.json
```

After a couple of minutes, we will have our Node app ready.


[Install and configure the Azure Cross-Platform Command-Line Interface](https://docs.microsoft.com/es-es/cli/azure/install-azure-cli?view=azure-cli-latest)

