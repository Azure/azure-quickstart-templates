# Parameterized Linked Templates

This sample template will deploy multiple tiers of resources into an Azure Resource Group.  Each tier has configurable elements, to show how you can expose parameterization to the end user.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/parameterized-linked-templates/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/parameterized-linked-templates/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/parameterized-linked-templates/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/parameterized-linked-templates/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/parameterized-linked-templates/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/parameterized-linked-templates/CredScanResult.svg)

## Deploy this template to Azure
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fparameterized-linked-templates%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fparameterized-linked-templates%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fparameterized-linked-templates%2Fazuredeploy.json)

*Note: If you fork this repository, you will need to modify the link in [README.md](README.md) to point to your repo.  If you create a separate branch for testing, you will have to include a change to this link to point to your branch as well. You must include a URL-encoded link to the raw [azuredeploy.json](azuredeploy.json) file after `/uri/` in the link defined for the deployment button. You should also change the default value of `_artifactsLocation`.* 

## Overview

### Front End
There are three user accessible front-ends for the deployment:
* An Azure Bastion Service deployed into the VNET to allow ssh access to VMs that do not have public IP addresses.
* An Azure App Gateway that will load balance HTTP requests on port 80 to the back-end tier nodes.
* An Azure VM "Jump box" that allows ssh access, and which also has a custom startup script that uses the private ip addresses gathered from the back-end.

All 3 front-ends are protected by Network Security Groups and only allow access from an IP address or CIDR provided in the deployment parameters.

### Middle Tier
The middle-tier currently serves no purpose other than to demonstrate variable configuration deployment of 0, 1, or 3 VMs as is seen in services that include a high-availability configuration when deployed.

### Back End
Each node in the back-end tier currently runs a script to start a simple web server on port 80 (See [examplePostInstall2.sh](scripts/examplepostinstall2.sh)).  The web server will display a static html file that includes the virtual machine name retrieved from the [Azure Instance Metadata Service](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/instance-metadata-service).

## Topics Covered:

#### [Naming Parameters to be User Friendly](detail/userfriendlyparameters.md)
#### [Using Variables to Centralize Configurable Elements](detail/complexvariables.md)
#### [Use Linked Template for Multiple Resources (IaaS)](detail/vmtemplate.md)
#### [Use Linked Template to Limit Main Template Complexity (App Gateway)](detail/agtemplate.md)

`Tags: ARM, Variables, Parameters, Linked Templates, IaaS`
