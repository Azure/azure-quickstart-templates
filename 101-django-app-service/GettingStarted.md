## Django App - App Service 

The intent of this README is to deploy a Django App. This template was designed to be an easy and fast way to create an App Service to deploy your Django App.

You can deploy this template by using the [Azure Portal](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-portal) or [Azure CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-cli). Let's dig on the template and have some fun coding. 

### The template

In the template we will have different sections. These sections are:

    - Parameters
    - Variables
    - Resources

Let's see each section.

#### Parameters

The parameters are fields that we should modify of our App Service.
Here, we will find only a parameter: 

|**PARAMETERS NAME**   |**DESCRIPTION**   |
|---|---|
|name   |Name for your application. It has to be unique.   |


To ensure that this name is unique, we will add to that name, the name of the resource group where we will deploy the App Service to the name field. The format will be like follows:

```
<appServiceName>-<resourceGroupName>
```

#### Variables

The variables are fields that we should not modify. That's because it is configured to get our App Service deployed into a Free tier.

On that template, we have the following variables:

|**VARIABLES NAME**   |**DESCRIPTION**   |
|---|---|
|subscriptionId   |ID of our subscription   |
|location   |Variable to retrieve the location from your Resource Group and apply for all other resources.   |
|hostingEnvironment   |Name of the App Service Environment. If you don't know if you need it, you should leave it empty. Here you can see some [documentation](https://docs.microsoft.com/en-in/azure/app-service/environment/intro)   |
|serverFarmResourceGroup   |Name of the resource group where our serverFarm is.   |
|alwaysOn   |It allows us to have the app On even if it is no traffic.   |
|sku   |Shape for our product.   |
|skuCode   |Code to identify our product.   |
|workerSize   |Optional. The worker size. Possible values are Small, Medium, and Large. For JSON, the equivalents are 0 = Small, 1 = Medium, and 2 = Large   |
|workerSizeId   |Gets or sets size ID of machines: 0 - Small 1 - Medium 2 - Large   |
|numberOfWorkers   |Gets or sets number of workers.   |
|linuxFxVersion   |The Linux APP Framework and version.   |
|hostingPlanName   |Name for the hosting plan. On free tier, you can only have 1 linux hosting environment.   |

#### Resources

The resources are the services that we will to deploy into Azure. In this template we will deploy two resources:

|**RESOURCE NAME**   |**DESCRIPTION**   |
|---|---|
|Microsoft.Web/sites   |This is our App Service.   |
|Microsoft.Web/serverfarms   |This is the hosting for our App Service. There is a limit of 1 free tier linux server per subscription.   |
|microsoft.insights/components   |Used to monitor our live web application   |

## Deployment

There are a few ways to deploy this template.
You can use [PowerShell](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy), [Azure CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-cli), [Azure Portal](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-portal) or your favorite SDK.

For this task, we will deploy using the Portal and Azure CLI, I choose to use the Visual Code with Azure CLI extensions, if you like, you can find more information [here](https://code.visualstudio.com/docs/azure/extensions). But bare in mind that you don't need to use the Visual Code, you can stick with the old good always present **Command Line** on Windows or any **bash terminal**.

### Using Azure CLI with Visual Code
Type on the terminal windows: 

```
az login
```

![Screen](./images/az-log.png)

You gonna be redirected to the Azure Portal where you can use your credentials to login into.

After login, you gonna have your credentials. 

In order to set the right subscription, you can use the follow command:

```
az account set --subscription "< your subscription id >"
```

### Resource Group

A resource group is a container that holds related resources for an Azure solution. The resource group includes those resources that you want to manage as a group. 

We gonna need to create a resource group for our deployment if we haven't yet create a resource group.

To create a resource group, we will need a name and the location. For a list of locations, type:

```
az account list-locations
```

To create the resource group, just type the command:

```
az group create --name <mygroupname> --location <thelocation>
```

![Screen](./images/az-groupcreate.png)

Now, we are ready to deploy our template. Type the next command to get it:

```
az group deployment create --resource-group <your resource-group name> --template-file <full path and name of your template>
```

![Screen](./images/az-group-deploy.png)

It will spend some time on the deployment. Bring it like 5 minutes until the process finish.

When it finished, let's go to the Portal, and let's see our App Services.

![Screen](./images/portal-resource.png)

Congratulations! You have deployed the template succesfully. We can see our web visiting an url like that:

```
<app-name>.azurewebsites.net
```

![Screen](./images/django-app-service.png)

You can redeploy it automatically with just click on this button:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure4StudentQSTemplates%2Fazure-quickstart-templates%2Fmaster%2F101-django-app-service%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure4StudentQSTemplates%2Fazure-quickstart-templates%2Fmaster%2F101-django-app-service%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>


### Deploy your code

It will be really easy. First of all, download the basic django project configuration from [Azure-Sample](https://github.com/Azure-Samples/docker-django-webapp-linux.git). You can clone the repository using git. 

![Screen](./images/git-clone.png)

Once we have cloned the repository, let's create a new repository in GitHub. Here is where we will push our Django App to make the deployment. Let's now go to the portal, to the deployment center in our App Service Resource.

![Screen](./images/app-service.png)

Let's click on "Get Started" and then select the GitHub option. If it is the first time you make this, you will have to syncronize your GitHub and Azure account.
Select next ... And then select the repository and the branch. 

If we make all good, the system will recognize our dockerfile automatically. Finally, we will have to create an Azure DevOps and a Container Registry on the last step of the deployment or use an existing one.

![Screen](./images/build.png)

Make sure that it is deployed succesfully to production. Now we can see our own django app deployed in our app services.

![Screen](./images/new-django-app-service.png)

### How to delete your resources

On the portal, open your resource group and click on the Delete button.

![Screen](./images/delete-rsc.png)

### What to do if deployment fails

When we are trying to deploy our template, we can find that this fails. If that happens, what we will do it is to delete the resource group and then redeploy our template.

To delete the resource group, we will go to our resource group, and then, we will delete it exactly the same that we made on the last section.