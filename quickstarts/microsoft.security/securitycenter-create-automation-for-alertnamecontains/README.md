# Deploy an Azure Security Center Automation for a specific Azure Security Center alerts

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.security/securitycenter-create-automation-for-alertnamecontains/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.security/securitycenter-create-automation-for-alertnamecontains/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.security/securitycenter-create-automation-for-alertnamecontains/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.security/securitycenter-create-automation-for-alertnamecontains/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.security/securitycenter-create-automation-for-alertnamecontains/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.security/securitycenter-create-automation-for-alertnamecontains/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.security%2Fsecuritycenter-create-automation-for-alertnamecontains%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.security%2Fsecuritycenter-create-automation-for-alertnamecontains%2Fazuredeploy.json)

This template deploys an Azure Security Center Automation which will be triggered by Azure Security alerts which their display name contains a specific string.
Automation is an Azure Resource which triggers a Logic App.

## Overview and deployed resources

This is an overview of the solution

The following resources are deployed as part of the solution

### Microsoft.Logic Resource provider

The Microsoft.Logic Resource provider is used to create an empty triggerable Logic App.

- **Logic App**: An empty triggerable Logic App.

### Microsoft.Security Resource provider

The Microsoft.Security Resource provider (Azure Security Center) is where the Automation which will trigger the logic app will be created.

- **Automation**: The automation that triggers the empty Logic App upon receiving an Azure Security Center alert that contains a specific string. In our example the alert triggering rule is **Virtual Machine** and has a severity of either **Medium**, **High**, **Low**.

## Prerequisites

Users need to be registered to both Microsoft.Logic and Microsoft.Security resource providers to run this deployment.

## Deployment steps

You can select the **Deploy to Azure** button at the beginning of this document. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/security-center/quickstart-automation-alert) article.

## Notes

Solution notes

`Tags: Security, Security Center, LogicApps, Automations`
