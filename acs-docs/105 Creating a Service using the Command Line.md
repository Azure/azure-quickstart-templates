105: Creating a Service using the Command Line

Thursday, November 19, 2015

1:09 PM

 

To access Azure Container Service using the command line, you will need an Azure subscription. If you don't have one then you can sign up for a [free trial](http://www.windowsazure.com/en-us/pricing/free-trial/?WT.mc_id=AA4C1C935). You will also need to have installed and configured either the [Azure CLI](https://azure.microsoft.com/en-us/documentation/articles/xplat-cli/) (cross platform) or the [Azure PowerShell Azure](https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/).

 

Select an ARM template from [rgardler's fork](https://github.com/rgardler/azure-quickstart-templates) of the Azure QuickStarts repo in Github. All Azure Container Service Templates start with 'acs-'

 

There are two templates of particular interest:

 

-   Mesos: <https://github.com/rgardler/azure-quickstart-templates/tree/acs/acs-mesos-full-template>

-   Swarm: <https://github.com/rgardler/azure-quickstart-templates/tree/acs/acs-swarm-full-template>

 

Using the Azure CLI (Cross Platform)

 

First you need to ensure that your CLI tools are configured to use Azure Resource manager. This is done with:

 

azure config mode arm

 

If you want to create your cluster in a new Resource Group you must first create the Resource Group. Use this command:

 

azure group create GROUP\_NAME REGION

 

Where GROUP\_NAME is the name of the resource group you want to create, and REGION is the region where you want to create the Resource Group.

 

Once you have a Resource Group you can create your cluster with:

 

azure group deployment create RESOURCE\_GROUP DEPLOYMENT\_NAME

--template-uri TEMPLATE\_URI

Where:

RESOURCE\_GROUP is the name of the Resource Group you want to use for this service

DEPLOYMENT\_NAME is the name of this deployment

TEMPLATE\_URI is the location of the deployment file. Note that this must be the RAW file, not a pointer to the GitHub UI. To find this URL select the azuredeploy.json file in GitHub and click the RAW button:

 

![](images\105/media/image1.png)

 

Providing a Parameters file

 

This version of the command requires the user to define parameters interactively. If you want to provide a parameters file in json format you can do so with the '-p' switch. For example:

 

azure group deployment create RESOURCE\_GROUP DEPLOYMENT\_NAME

--template-uri TEMPLATE\_URI -p '{ "param1": "value1" … }'

 

There is an example parameters file (called 'azuredeploy.parameters.json') in GitHub alongside each template.

 

PowerShell

 

First you need to ensure that your PS tool is configured to use Azure Resource manager. This is done with:

 

Switch-AzureMode AzureResourceManager

 

If you want to create your cluster in a new Resource Group you must first create the Resource Group. Use this command:

 

New-AzureRmResourceGroup -Name GROUP\_NAME -Location REGION

 

Where GROUP\_NAME is the name of the resource group you want to create, and REGION is the region where you want to create the Resource Group.

 

 

Once you have a Resource Group you can create your cluster with:

 

New-AzureResourceGroupDeployment -Name DEPLOYMENT\_NAME -ResourceGroupName RESOURCE\_GROUP\_NAME -TemplateUri TEMPLATE\_URI

 

 

Dynamic Template Parameters

 

If you are familiar with PowerShell, you know that you can cycle through the available parameters for a cmdlet by typing a minus sign (-) and then pressing the TAB key. This same functionality also works with parameters that you define in your template. As soon as you type the template name, the cmdlet fetches the template, parses it, and adds the template parameters to the command dynamically. This makes it very easy to specify the template parameter values. And, if you forget a required parameter value, PowerShell prompts you for the value.

 

Below is the full command with parameters included. You can provide your own values for the names of the resources.

 

New-AzureRmResourceGroupDeployment -ResourceGroupName RESOURCE\_GROUP\_NAME-TemplateURI TEMPLATE\_URI -param1 value1 -param2 value2 …..
