# OMS Kemp Application Delivery Solution

## Prerequisites

The solution displays data collected from the Kemp devices through an extension for [OMS agent for Linux](https://github.com/Microsoft/OMS-Agent-for-Linux). The instructions on how to install and configure the agent extension are on a separate [github repo](https://github.com/QuaeNocentDocent/omskemp)

This solution will display status, assets and performance data from your [Kemp](www.kemptechnologies.com) Application Delivery (was loadmaster) in your OMS Log Analytics workspace.

![SolutionOverview](images/overview.png?raw=true)


## Installation

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Foms-kemp-applicationdelivery-solution%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Foms-kemp-applicationdelivery-solution%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

If you **don't** have an existing OMS Log Analytics Workspace, the template will create and deploy this for you, if you want to use an existing workspace you must first collect the workspace info.

To do that log into [Azure Portal](https://portal.azure.com) and ensure you are in the subscription containing the Log Analytics Workspace you want to use.

Locate your existing OMS Log Analytics Workspace and note the name of the workspace, the location of the workspace, and the Resource Group

![alt text](images/omsworkspace.png "omsws") 

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Foms-kemp-applicationdelivery-solution%2Fazuredeploy.json) 

This will send you to the Azure Portal with some default values for the template parameters. 
Ensure that the parameters reflects your setup so that you are deploying this into the *existing* Resource Group containing the Log Analytics Workspace

## How to remove the solution

In the unfortunate case you want to remove the solution you can do it from the the Azure [portal](https://portal.azure.com) in the Log Analytics workspace blade, under solutions, currently the predefined searches and alerts are not automatically removed. If you also want to get rid of them they can be manually deleted from "Saved searches" in the Log Analytics workspace blade.

`Tags: kemp, oms, msoms, solution, example, walkthrough, #msoms`