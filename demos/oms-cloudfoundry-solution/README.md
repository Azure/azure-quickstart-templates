# Azure OMS Log Analytics Solution for Cloud Foundry

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/oms-cloudfoundry-solution/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/oms-cloudfoundry-solution/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/oms-cloudfoundry-solution/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/oms-cloudfoundry-solution/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/oms-cloudfoundry-solution/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/oms-cloudfoundry-solution/CredScanResult.svg)

Version: [2018.6](./changelog.md "See change logs")

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Foms-cloudfoundry-solution%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Foms-cloudfoundry-solution%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Foms-cloudfoundry-solution%2Fazuredeploy.json)

## Overview

This solution allows you to visualize and monitor the metrics and logs from your Cloud Foundry environments in OMS Log Analytics.

In order to use this solution, you must have

1. A Cloud Foundry deployment
1. The [Azure Log Analytics Firehose Nozzle](https://github.com/Azure/oms-log-analytics-firehose-nozzle) deployed to your Cloud Foundry environment.
1. _(Optional, recommended)_ The [Microsoft Azure OMS Linux Agent](https://github.com/Azure/oms-agent-for-linux-boshrelease) deployed to your Cloud Foundry environment.
1. _(Optional, might not be compatible with `Microsoft Azure OMS Linux Agent`)_ The [Microsoft Azure OMS Linux Agent Bosh Release](https://github.com/Azure/oms-agent-for-linux-boshrelease) deployed to your Cloud Foundry environment.

This template can create a new Log Analytics workspace and deploy the following resources into the workspace, or deploy the following resources into an existing Log Analytics workspace.

* All OMS views defined [here](https://github.com/Azure/oms-log-analytics-firehose-nozzle/tree/master/docs/omsview) for Cloud Foundry metrics and logs
* Predefined [alerts](https://github.com/Azure/oms-log-analytics-firehose-nozzle#2-create-alert-rules) for all KPI events from Cloud Foundry environments
* Predefined saved searches for major Cloud Foundry metrics and logs

## Installation

Follow these instructions to deploy the template:

1. If you want to use an existing Log Analytics workspace, note the name, location and resource group name of the workspace from [Azure Portal](https://portal.azure.com).

    ![workspace](https://documentimages.blob.core.windows.net/azurequickstarttemplatereadme/workspaceInAzure.png "workspace")

1. Click "Deploy to Azure", this will send you to the Azure Portal with some default values for the template parameters.

    [![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Foms-cloudfoundry-solution%2Fazuredeploy.json)

1. Fill the parameters.

    ![deploy](https://documentimages.blob.core.windows.net/azurequickstarttemplatereadme/deploy.png "deploy")

    1. `Subscription`: Select the subscription where your existing workspace is located, or where you want to create a new workspace
    1. `Resource group`: Select the resource group where your existing workspace is located, or enter a resource group name for your new workspace
    1. `Location`: Select the region of the resource group. If you're using an existing workspace, make sure you input correct location here
    1. `OMS Workspace Name`: Enter the name of your existing workspace. A new workspace with this name will be created if it does not exist
    1. `OMS Workspace Region`: Select the region where your existing workspace is located, or select a region for your new workspace
    1. `Azure Monitor Pricing Model`*: Select Azure Monitor pricing model your subscription has enabled. _Note that April 2018 pricing model would be enabled automatically if you onboard Azure Monitor later than April 2, 2018_
    1. `OMS Workspace Sku`: Select the pricing tier of the workspace. _Note that `PerGB2018` would be the only valid Sku if your subscription has enabled April 2018 pricing model. Thus, this parameter would be ignored if `April 2018` is selected for `Azure Monitor Pricing Model`_
    1. `System Metrics Provider`: Select provider for your system metrics, could be `Microsoft Azure OMS Agent`, `BOSH Health Metrics Forwarder` or both.

        _*Please refer to document [here](https://docs.microsoft.com/en-us/azure/monitoring-and-diagnostics/monitoring-usage-and-estimated-costs#new-pricing-model-and-operations-management-suite-subscription-entitlements) for more detail about Azure Monitor April 2018 pricing model._

1. Once you have customized all the parameters, click *Purchase*.

_Please refer to document [here](https://github.com/Azure/oms-agent-for-linux-boshrelease) for instructions to install `Microsoft Azure OMS Linux Agent`._

_Please refer to document [here](https://github.com/cloudfoundry/bosh-hm-forwarder-release) for instructions to install `BOSH Health Metrics Forwarder`._

_Be aware that there might be compatibility issue if you choose to use both `Microsoft Azure OMS Agent` and `BOSH Health Metrics Forwarder` in a single one Cloud Foundry environment._

## Customization and Upgrade

This template only deploys default resources with default settings, you might want to customize them to fit your needs.

If there are new features of this template you wish to use, you can redeploy the template by clicking the `Deploy to Azure` button on top to sync with all the latest features provided by our templates.

__ALERT: Redeploy this template(`azuredeploy.json`) is equivalent to deploy all nested templates in folder `/nested`, please reefer to explanations of redeploying these nested templates below and make sure you understand it will cause customization loss.__

Also notice that `OMS Log Analytics workspace` itself will not be modified during a redeployment. Thus your logs already in the workspace will not be lost and you don't have to change settings of neither `Microsoft Azure Log Analytics Nozzle` nor `Microsoft Azure OMS Agent`.

### Customize and Upgrade Views

To Customize view, you can refer to instructions [here](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-view-designer#import-an-existing-view).

To upgrade views, you can delete corresponding solutions from azure portal and then click [here](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Foms-cloudfoundry-solution%2Fnested%2FomsCustomViews.json) to redeploy nested view templates. __Make sure you know this will overwrite your customization made to corresponding views.__

You can also import new views manually. Views included in this template are located in repository `Microsoft Azure Log Analytics Nozzle` [here](https://github.com/Azure/oms-log-analytics-firehose-nozzle/tree/master/docs/omsview). Please download views you wish to add and refer to document [here](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-view-designer#import-an-existing-view) on how to import them.

As you may noticed, you may export an existing view if you wish to preserve your customization. Please refer to document [here](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-view-designer#export-an-existing-view) on how to do that.

### Customize and Upgrade Alerts

To upgrade alerts, you can click [here](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Foms-cloudfoundry-solution%2Fnested%2FomsAlerts.json) to redeploy nested view templates. __Make sure you know this will overwrite your customization made to alerts and corresponding saved searches EVEN you changed its original display name.__

To add or customize alerts, please refer to document [here](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-alerts-creating) for instruction.

_Reference document for query language in OMS Log Analytics can be found [here](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-search-reference). You may also consult our template of alerts [here](./nested/omsAlerts.json)._

### Customize and Upgrade Saved Searches

To upgrade saved searches, you can click [here](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Foms-cloudfoundry-solution%2Fnested%2FomsSavedSearches.json) to redeploy nested saved searches templates. __Make sure you know this will also overwrite your customization made to saved searches EVEN you haved changed its display name.__

To customize or create new saved searches, please login to `Microsoft Azure` portal, find and enter corresponding resource of `Log Analytics Workspace`. In page `Saved searches` under category `General`, you will find a complete list of saved searches of this workspace. Besides creating new saved searches, you can also execute, edit or delete existing searches here. _You can also save your current search in `Log Search` page of OMS portal by clicking `Save` button._

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

OMS also provides mobile apps available on [Windows (Mobile devices)](https://www.microsoft.com/en-us/store/p/microsoft-operations-management-suite/9wzdncrfjz2r), [Android](https://play.google.com/store/apps/details?id=com.microsoft.operations.AndroidPhone) and [iOS](https://itunes.apple.com/us/app/microsoft-operations-management-suite/id1042424859), for users to view OMS views, receiving alerts and searching for logs from your mobile devices.

Simply download App from your app store and login with your account, you can have experience just the same as on your workplace everywhere.

## [Change Logs](./changelog.md "See change logs")


