# Azure OMS Log Analytics Solution for Cloud Foundry

[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Foms-cloudfoundry-solution%2F%2Fazuredeploy.json)
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Foms-cloudfoundry-solution%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Overview

This solution allows you to visualize and monitor the metrics and logs from your Cloud Foundry environments in OMS Log Analytics.

In order to use the workspace created by this template, you must have

1. A Cloud Foundry deployment
1. The [Azure Log Analytics Firehose Nozzle](https://github.com/Azure/oms-log-analytics-firehose-nozzle) deployed to your Cloud Foundry environment.
1. _(Optional, recommended)_ The [Microsoft Azure OMS Linux Agent](https://github.com/Azure/oms-agent-for-linux-boshrelease) deployed to your Cloud Foundry environment.
1. _(Optional, might not compatible with `Microsoft Azure OMS Linux Agent`)_ The [Microsoft Azure OMS Linux Agent Bosh Release](https://github.com/Azure/oms-agent-for-linux-boshrelease) deployed to your Cloud Foundry environment.

This template can create a new Log Analytics workspace and deploy the following resources into the workspace, or deploy the following resources into an existing Log Analytics workspace.

* all the [OMS views](https://github.com/Azure/oms-log-analytics-firehose-nozzle/tree/master/docs/omsview) for Cloud Foundry metrics and logs
* predefined [alerts](https://github.com/Azure/oms-log-analytics-firehose-nozzle#2-create-alert-rules) for important events from Cloud Foundry environments
* predefined saved searches for major Cloud Foundry metrics and logs

## Installation

Follow these instructions to deploy the template:

1. If you want to use an existing Log Analytics workspace, note the name, location and resource group name of the workspace from [Azure Portal](https://portal.azure.com).

    ![workspace](https://documentimages.blob.core.windows.net/azurequickstarttemplatereadme/workspaceInAzure.png "workspace")

1. Click "Deploy to Azure", this will send you to the Azure Portal with some default values for the template parameters.

    [![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Foms-cloudfoundry-solution%2Fazuredeploy.json)

1. Fill the parameters.

    ![deploy](https://documentimages.blob.core.windows.net/azurequickstarttemplatereadme/deploy.png "deploy")

    1. `Subscription`: Select the subscription where your existing workspace is located, or where you want to create a new workspace
    1. `Resource group`: Select the resource group where your existing workspace is located, or enter a resource group name for your new workspace
    1. `Location`: Select the region of the resource group. If you're using an existing workspace, make sure you input correct location here
    1. `OMS Workspace Name`: Enter the name of your existing workspace, or enter a name for your new workspace
    1. `OMS Workspace Region`: Select the region where your existing workspace is located, or select a region for your new workspace
    1. `OMS Workspace Sku`: Select the pricing tier of the workspace
    1. `System Metrics Provider`: Select provider for your system metrics, could be `Microsoft Azure OMS Agent`, `BOSH Health Metrics Forwarder` or both. We highly recommended that you choose to use `Microsoft Azure OMS Agent` that it would be bundled into `Azure Log Analytics Firehose Nozzle` in the near future.
1. Once you have customized all the parameters, click *Purchase*.

_Please refer to document [here](https://github.com/Azure/oms-agent-for-linux-boshrelease) for instructions to install `Microsoft Azure OMS Linux Agent`._

_Please refer to document [here](https://github.com/cloudfoundry/bosh-hm-forwarder-release) for instructions to install `BOSH Health Metrics Forwarder`._

_Be aware that there might be compatibility issue if you choose to use both `Microsoft Azure OMS Agent` and `BOSH Health Metrics Forwarder` in a single one Cloud Foundry environment._

## Exploring the workspace

The template will deploy several views bundled in 3 solutions to your `Log Analytics` workspace along with alerts and saved searches.

![resource group](https://documentimages.blob.core.windows.net/azurequickstarttemplatereadme/resourceGroup.png "resource group")

_Solution named `AlertManagement` is a solution from OMS marketplace provided by `Microsoft` to manage alerts in a more visible and more interactive way._

Once the template has been deployed successfully, you need to deploy the [Microsoft Azure Log Analytics Nozzle](https://github.com/Azure/oms-log-analytics-firehose-nozzle) to collect Cloud Foundry metrics and logs to the workspace. If the workspace is newly created, it might take several minutes for data to be injected after the nozzle is started.

We also recommend you to deploy [Microsoft Azure OMS Linux Agent Bosh Release](https://github.com/Azure/oms-agent-for-linux-boshrelease) to collect VM data.

### Views

You can view oms portal inside portal of Microsoft Azure. Navigate to the OMS Log Analytics workspace in your resource group. on the `overview` page, multiple views should be already imported.

_You can also click `OMS Portal` button to visit legacy OMS portal._

![overview](https://documentimages.blob.core.windows.net/azurequickstarttemplatereadme/overview.png "overview")

Click on each view and more dashboards will be displayed.

![view](https://documentimages.blob.core.windows.net/azurequickstarttemplatereadme/view.png "view")

### Alerts

Go to `Settings` -> `Alerts` in OMS portal), there're 8 predefined alerts. You could edit and customize these alerts.

![alerts](https://documentimages.blob.core.windows.net/azurequickstarttemplatereadme/alerts.png "alerts")

### Log Search

Go to `Log Search` in your workspace (or `Log Search` in OMS portal), you could find log search page which is another key feature of `OMS` `Log Analytics`. You can search in logs and generate fancy graphs or charts with its [query language](https://docs.loganalytics.io/docs/Language-Reference/).

![log search](https://documentimages.blob.core.windows.net/azurequickstarttemplatereadme/logSearch.png "log search")

### Saved Searches

Go to `Saved Searches` in your workspace (or `Log Search` -> `Favorites` in OMS portal), you could find categorized search queries for major Cloud Foundry metrics and logs.

![saved searches](https://documentimages.blob.core.windows.net/azurequickstarttemplatereadme/savedSearches.png "saved searches")

### Monitor your environment Everywhere

OMS also provides mobile apps for users to view OMS views, receiving alerts and searching for logs from your mobile devices.

Simply download App from your app store and login with your account, you can have experience just the same as on your workplace everywhere.

OMS Apps now available on [Windows (Mobile devices)](https://www.microsoft.com/en-us/store/p/microsoft-operations-management-suite/9wzdncrfjz2r), [Android](https://play.google.com/store/apps/details?id=com.microsoft.operations.AndroidPhone) and [iOS](https://itunes.apple.com/us/app/microsoft-operations-management-suite/id1042424859) devices.
