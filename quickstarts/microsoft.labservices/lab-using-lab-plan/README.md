---
description: Create Azure Lab Services lab using a lab plan.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: lab-using-lab-plan
languages:
- json
- bicep
---
# Create Azure Lab Services lab using a lab plan.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.labservices/lab-using-lab-plan/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.labservices/lab-using-lab-plan/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.labservices/lab-using-lab-plan/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.labservices/lab-using-lab-plan/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.labservices/lab-using-lab-plan/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.labservices/lab-using-lab-plan/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.labservices/lab-using-lab-plan/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.labservices%2Flab-using-lab-plan%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.labservices%2Flab-using-lab-plan%2Fazuredeploy.json)

This template deploys a Lab for Azure Lab Services. The lab is a collection for virtual machines grouped together for groupings of users, like a class in a school.

## Sample overview and deployed resources

The following resources are deployed as part of the solution

1. A Lab

## Prerequisites

- An Azure Lab Services lab plan.  The lab plan is a collection of settings used during lab creation.  This includes allowed Azure Marketplace images and locations the lab may be created in.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

`Tags: LabServices, lab, Microsoft.LabServices/labs, Microsoft.LabServices/labPlans`