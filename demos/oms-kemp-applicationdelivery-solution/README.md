# OMS Kemp Application Delivery Solution

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/oms-kemp-applicationdelivery-solution/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/oms-kemp-applicationdelivery-solution/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/oms-kemp-applicationdelivery-solution/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/oms-kemp-applicationdelivery-solution/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/oms-kemp-applicationdelivery-solution/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/oms-kemp-applicationdelivery-solution/CredScanResult.svg)

## Prerequisites

The solution displays data collected from the Kemp devices through an extension for [OMS agent for Linux](https://github.com/Microsoft/OMS-Agent-for-Linux). The instructions on how to install and configure the agent extension are on a separate [github repo](https://github.com/QuaeNocentDocent/omskemp)

This solution will display status, assets and performance data from your [Kemp](www.kemptechnologies.com) Application Delivery (was loadmaster) in your OMS Log Analytics workspace.

![SolutionOverview](images/overview.png?raw=true)

## Installation

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Foms-kemp-applicationdelivery-solution%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Foms-kemp-applicationdelivery-solution%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Foms-kemp-applicationdelivery-solution%2Fazuredeploy.json)

If you **don't** have an existing OMS Log Analytics Workspace, the template will create and deploy this for you, if you want to use an existing workspace you must first collect the workspace info.

To do that log into [Azure Portal](https://portal.azure.com) and ensure you are in the subscription containing the Log Analytics Workspace you want to use.

Locate your existing OMS Log Analytics Workspace and note the name of the workspace, the location of the workspace, and the Resource Group

![alt text](images/omsworkspace.png "omsws") 

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Foms-kemp-applicationdelivery-solution%2Fazuredeploy.json) 

This will send you to the Azure Portal with some default values for the template parameters. 
Ensure that the parameters reflects your setup so that you are deploying this into the *existing* Resource Group containing the Log Analytics Workspace

## How to remove the solution

In the unfortunate case you want to remove the solution you can do it from the the Azure [portal](https://portal.azure.com) in the Log Analytics workspace blade, under solutions, currently the predefined searches and alerts are not automatically removed. If you also want to get rid of them they can be manually deleted from "Saved searches" in the Log Analytics workspace blade.

`Tags: kemp, oms, msoms, solution, example, walkthrough, #msoms`


