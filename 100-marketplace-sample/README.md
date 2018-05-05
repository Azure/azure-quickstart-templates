# Azure Marketplace VM with CreateUIDefinition

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F100-marketplace-sample%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>


This template allows deploying a linux VM using new or existing resources for the Virtual Network, Storage and Public IP Address.  It also allows for choosing between SSH and Password authenticate.  The templates uses conditions and logic functions to remove the need for nested deployments. 

This template contains extra parameters to allow for the existing resources use cases, which is a common scenario for Azure Applications in the Azure Marketplace.

createUiDefinition.json is also included.

`Tags: new, exiting, resource, vm, condition, conditional`
