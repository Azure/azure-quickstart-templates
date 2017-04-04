# Azure Service Bus Monitoring

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Foms-servicebus-solution%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This solution (currently in preview) will allow you to capture your Azure Service Bus metrics and visualize them in Operations Management Suite (Log Analytics). This solution leverages an automation runbook in Azure Automation, the Log Analytics Ingestion API, together with Log Analytics views to present data about all your Azure Service Bus instances in a single Log Analytics workspace. 

![alt text](images/ServiceBusSolution.png "Solution View")

**Updates in this version (April 2017):**
+ Added more fields for Topics
+ Added a free space remaining percentage for Queue and Topic thresholds
+ Before ingestion, added an alert threshold value if Queue and/or Topic threshold is reached, so that you can create an alert based on this value
+ Updated visualization with free space remaining for queues and topics, scheduled messages etc.
 
![alt text](images/FreeSpaceAndAlertThreshold.png "Free space percentage and Alert Threshold")

## Prerequisites

+ Azure Subscription (if you don't have one you can create one [here](https://azure.microsoft.com/en-us/free/))
+ New Azure Automation Account (with a RunAs Account AND a Classic RunAs account). To create a new Automation Account refer to step 1 below.+ The schedule (which automatically will be created during deployment) to run the runbook requires a unique GUID, please run the PowerShell command "New-Guid" to generate one

**Note: The OMS Workspace and Azure Automation Account MUST exist within the same resource group. The Azure Automation Account name needs to be unique.**

## How do I get started?

**Create a new Automation account**: Go the Azure Portal https://portal.azure.com and create an Azure Automation account (do not link it to your OMS workspace).

If you have an existing OMS Log Analytics workspace in a Resource Group, proceed to create the Automation account in this Resource Group. It is recommended that the Azure region is the same as the OMS Log Analytics resource. By default, the wizard will create an SPN account as part of this process.

Note: Make sure to create the new Automation Account leveraged for this solution in the subscription that you are wanting to monitor the Azure Service Bus instances. If you don't have an existing OMS Log Analytics workspace in a Resource Group the template deployment will create one for you, create a new Automation account into a new Resource Group. A SPN account will be created by default.

**Note: An Azure Automation account needs to exist before deploying this solution, do not link it to your OMS workspace**

Click the button that says **Deploy to Azure**. This will launch the ARM Template you need to configure in the Azure Portal:

![alt text](images/step3deploy.png "Deployment in the portal")




**Deployment Settings**

1. Provide the name of the resource group in which your new Azure Automation account resides (which you've created in step 1), **so select "Use existing"** . The resource group location will be automatiocally filled in.

2. Under "Settings" provide the name and the region of an existing OMS workspace. If you don't have an OMS workspace, the template deployment will create one for you.

3. Under "Oms Automation Account Name" provide the Automation Account name (which you've created in step 1) and the region where the Automation Account resides in.

4. Provide an unique Job Guid (this will be used to create a runbook schedule). You can generate a unique Job Guid in PowerShell like this:

![alt text](images/NewGuid.png "Generate a new GUID in PowerShell")

Accept the "Terms and Conditions" and click on "Purchase"

                               

## Monitoring multiple subscriptions

The solution is designed to monitor Azure Service Bus instances across subscriptions.
To do so, you simply have to deploy this template and provide the workspace Id and the workspace Key for the workspace where you already have deployed the solution.

## Pre-reqs

- **Automation Account with SPN**

Due to specific dependencies related to modules, variables and more, the solution requires that you create additional Azure Automation accounts when scaling the solution to collect data from multiple subscriptions. You must create an Automation Account in the Azure portal with the default settings so that the SPN account will be created.


- **OMS workspace Id and Key**

This template will have parameters that will ask for the WorkspaceID and the WorkspaceKey, so that the runbooks are able to authenticate and ingest data.
You can log in to the OMS classic portal and navigate to Settings --> Connected Sources to find these values

Once you have completed the pre-reqs, you can click on the deploy button below

**Deployment Settings**

1. Provide the name of the resource group in which your Azure Automation account resides (which has access to the additional subscriptions you want to add), **so select "Use existing"** . The resource group location will be automatiocally filled in.
2. Enter the WorkspaceID and WorkspaceKey for the existing workspace you want this additional subscription service bus data to flow in.
3. Enter the OMS Automation Account Name and its region
4. Enter an unique jobID (use PowerShell's New-Guid command to generate one)
5. Accept the terms and conditions and click on Purchase

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Foms-servicebus-solution%2Fnestedtemplates%2FaddMultipleSubscriptions.json) 


Once deployed you should start to see data from your additional subscriptions flowing into your workspace.
