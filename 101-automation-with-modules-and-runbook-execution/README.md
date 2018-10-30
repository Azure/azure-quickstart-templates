# Automation account, modules updation and runbook to register AD App

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-automation-with-modules-and-runbook-execution%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-automation-with-modules-and-runbook-execution%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/AzureGov.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-automation-with-modules-and-runbook-execution%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates an automation account, updates modules and executes runbook that registers new application in active directory 


For details about Azure Operations Management services,
see the [Azure Automation Documentation](https://docs.microsoft.com/en-us/azure/automation/).

## What is new in this template

This template creates an automation account, imports and updates the AzureRM.Profile, AzureRM.Resources from powershell gallery. When these modules are updated, a runbook from storage account is scheduled and executed.
 This runbook creates an application into the active directory.

 Notice that no custom scripts or chained-together ARM templates are required in this example.

This template does not use any other nested template, it directly uses the following template and does above mentioned operations.

## What is unique about this concept

This templates describes how we can update the required modules to schedule and run a runbook, automatically.
 It does not use RunAsAccount to authenticate runbook to execute runbook. It asks Azure portal email and password from the user and uses these credentials to authenticate the runbook.
This contains powershell runbook that registers an application into active directory.
