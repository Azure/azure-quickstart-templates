# Automation account, modules updation and runbook execution to register Azure AD App

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-automation-with-modules-and-runbook-execution%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-automation-with-modules-and-runbook-execution%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/AzureGov.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-automation-with-modules-and-runbook-execution%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template demonstrates an automation account with updating modules and runbook execution that registers new application in active directory 


For details about Azure Operations Management services,
see the [Azure Automation Documentation](https://docs.microsoft.com/en-us/azure/automation/).

## What is new in this template

This template creates an automation account, imports and updates the AzureRM.Profile, AzureRM.Resources and AzureRM.Website from powershell gallery. When these modules are updated, a runbook from storage account is scheduled and executed.
 This runbook creates an application into the active directory and updates the web application settings, the web applicaion may be used to access and manage the Azure resources that do not support access through managed service identity.

 Notice that no custom scripts or chained-together ARM templates are required in this example.

This template does not use any other nested template, it directly uses the following template and does above mentioned operations.

## What is unique about this concept

This templates describes how we can update the required modules to schedule and run a runbook, automatically.
 It does not use RunAsAccount to authenticate runbook to execute runbook. It asks Azure portal email and password from the user and uses these credentials to authenticate the runbook.
This is powershell runbook that registers an application into active directory and automatically updates the settings of a web application.

This template is useful if you want to deploy any web application to Azure marketplace as managed application and want to manage Azure resources using this application(it may be rest api code or any sdk) with dynamically creating the service principal.
