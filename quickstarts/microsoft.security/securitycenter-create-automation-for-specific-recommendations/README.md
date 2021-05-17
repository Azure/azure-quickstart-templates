# Deploy an Azure Security Center Automation for an Azure Security Center recommendation

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.security/securitycenter-create-automation-for-specific-recommendations/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.security/securitycenter-create-automation-for-specific-recommendations/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.security/securitycenter-create-automation-for-specific-recommendations/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.security/securitycenter-create-automation-for-specific-recommendations/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.security/securitycenter-create-automation-for-specific-recommendations/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.security/securitycenter-create-automation-for-specific-recommendations/CredScanResult.svg)
    
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.security%2Fsecuritycenter-create-automation-for-specific-recommendations%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.security%2Fsecuritycenter-create-automation-for-specific-recommendations%2Fazuredeploy.json)


This template deploys an Azure Security Center Automation for a specific Azure Security Center's recommendation.
Automation is an Azure Resource which triggers a Logic App.

## Overview and deployed resources

This is an overview of the solution

The following resources are deployed as part of the solution

### Microsoft.Logic Resource provider

The Microsoft.Logic Resource provider is used to create an empty triggerable Logic App.

+ **Logic App**: An Empty triggerable Logic App

### Microsoft.Security Resource provider

The Microsoft.Security Resource provider (Azure Security Center) is where the Automation which will trigger the logic app will be created. 

+ **Automation**: The Automation which will trigger the empty Logic App, upon receiving a specific Azure Security Center recommendation.
In the example specified we have used the following recommendation (assessment) with the Guid : "4fb67663-9ab9-475d-b026-8c544cced439". 
This recommendation is for "Install endpoint protection solution on Linux virtual machines".

We found this Guid by using Azure Security Center assessment meta data API. 
The API is listed in:
https://docs.microsoft.com/en-us/rest/api/securitycenter/assessmentsmetadata

## Prerequisites

Users need to be registered to both Microsoft.Logic and Microsoft.Security resource providers to run this.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Notes

Solution notes

`Tags: Security, Security Center, LogicApps, Automations`


