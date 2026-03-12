---
description: This template creates an Azure Health Data Services workspace containing a FHIR and DICOM service with optional system-assigned managed identity.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: create-workspace-with-child-services
languages:
- bicep
- json
---
# Create Azure Health Data Services de-identification service

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/create-workspace-with-child-services/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/create-workspace-with-child-services/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/create-workspace-with-child-services/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/create-workspace-with-child-services/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/create-workspace-with-child-services/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/create-workspace-with-child-services/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/create-workspace-with-child-services/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.healthcareapis%2Fworkspaces%2Fcreate-workspace-with-child-services%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.healthcareapis%2Fworkspaces%2Fcreate-workspace-with-child-services%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](hhttp://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.healthcareapis%2Fworkspaces%2Fcreate-workspace-with-child-services%2Fazuredeploy.json)

This template allows you to deploy a new Azure Health Data Services workspace containing a FHIR and DICOM service. The [quickstart](/azure/healthcare-apis/deploy-healthcare-apis-using-bicep) article describes how to deploy the template.

For more information about Azure Health Data Services, see [What is Azure Healthcare Services?](/azure/healthcare-apis/healthcare-apis-overview).

`Tags: Microsoft.HealthDataAIServices/workspaces, Microsoft.HealthDataAIServices/workspaces/dicomservices, Microsoft.HealthDataAIServices/workspaces/fhirservices`
