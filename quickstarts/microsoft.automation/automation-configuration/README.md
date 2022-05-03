# Azure Automation Managed Node template

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/automation-configuration/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/automation-configuration/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/automation-configuration/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/automation-configuration/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/automation-configuration/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/automation-configuration/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.automation%2Fautomation-configuration%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.automation%2Fautomation-configuration%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.automation%2Fautomation-configuration%2Fazuredeploy.json)    


This template demonstrates a managed virtual machine where the configuration
will be maintained by Azure for the life of the node as opposed to only applying
the configuration at the time of deployment.

For details about Azure Operations Management services,
see the [Azure Automation Documentation](https://docs.microsoft.com/en-us/azure/automation/).

## What is new in this template

Unlike previous examples, this template includes examples of nested templates
that create an automation account, publish a configuration script and supporting modules
from the [PowerShell Gallery](http://www.powershellgallery.com),
compile the configuration, bootstrap the machine to the service,
and wait for the initial delivery of the configuration to complete,
all from a single deployment.
This is possible because new API methods (reference, listkeys) are now available
for the Automation service.

Notice that no custom scripts or chained-together ARM templates are required in this example.

There is one important concept to note when using nested templates such as this,
where dependencies flow across separate declared deployments.
In order for the Server template to "depend on" the Configuration template,
the Automation Account is declared again in the Server template.
Since the account already exists,
this is essentially verifying the account before the server deployment.

## What is unique about this concept

This model is the go-forward recommendation for utilizing DSC with Azure Virtual Machines.
The [DSC Extension](https://blogs.msdn.microsoft.com/powershell/2014/08/07/introducing-the-azure-powershell-dsc-desired-state-configuration-extension/)
is used only to apply settings to the Local Configuration Manager (LCM) and direct it
to use the [Azure Automation DSC](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-overview)
service to deliver *and maintain* the state of the machine.
The compliance state or any error messages from DSC can be viewed in the reporting
available with the service.

Users of the service also have tools to support Operations practices,
such as publishing changes to the configuration without re-deployment of the virtual machine,
or [linking the Automation Account with Log Analytics](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-diagnostics)
for alerting (including notifications to mobile devices) when a node has drifted from
the intended configuration.

## Is it acceptable to link directly to PowerShell Gallery in Azure-Quickstart-Templates?

The expected workflow from any public gallery is to download/save an artifact,
review the source code and test it to verify functionality,
and then publish it to a private, trusted feed for usage.
However, since module authors releasing to PowerShell Gallery increment the version number
when changes are made,
if template authors would like to validate and test *specific versions* of modules
in the gallery and use *static links* to those artifacts,
those artifacts can be expected to remain unchanged.
**This does not change the operational best practice behavior of reviewing, validating, and testing
all code artifacts including ARM templates, PowerShell scripts, and DSC resources,
before production deployment.**

