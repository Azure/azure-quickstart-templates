---
description: The MedTech service is an optional service of the Azure Health Data Services designed to ingest health data from multiple and disparate Internet of Medical Things (IoMT) devices and normalizes, groups, transforms, and persists device health data in the Fast Healthcare Interoperability Resources (FHIR®) service within an Azure Health Data Services workspace.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: iotconnectors
languages:
- json
- bicep
---
# Deploy an Azure Health Data Services MedTech service

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.healthcareapis%2Fworkspaces%2Fiotconnectors%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.healthcareapis%2Fworkspaces%2Fiotconnectors%2Fazuredeploy.json)

This template deploys an instance of the Azure Health Data Services MedTech service.

## Sample overview and deployed resources

The MedTech service is an optional service of the Azure Health Data Services designed to ingest health data from multiple and disparate Internet of Medical Things (IoMT) devices and normalizes, groups, transforms, and persists device health data in the Fast Healthcare Interoperability Resources (FHIR®) service within an Azure Health Data Services workspace.

As a part of this template, the following Azure resources and required access permissions are deployed within an existing or new Azure resource group:

* An Azure Event Hubs Namespace and device message Azure event hub (the event hub is named: devicedata).
* An Azure event hub consumer group (the consumer group is named: $Default).
* An Azure event hub sender role (the sender role is named: devicedatasender).
* An Azure Health Data Services workspace.
* An Azure Health Data Services FHIR service.
* An Azure Health Data Services MedTech service including the necessary system-assigned managed identity roles to the device message event   hub (Azure Events Hubs Receiver) and FHIR service (FHIR Data Writer).

**NOTE:** The MedTech service will still require a properly conforming device and FHIR destination mapping to be fully functional.

## Deployment steps

You can click the **Deploy to Azure** button at the beginning of this document to deploy an instance of the MedTech service.

While in the final configuration stage within the Azure portal, you can specify the service names and Azure region location (optional). By default, the deployment will use the region of the resource group that is select for the deployment. All other parameters for deployment are automatically configured for you.

FHIR® is a registered trademark of Health Level Seven International, registered in the U.S. Trademark Office and is used with their permission.

`Tags: Microsoft.EventHub/namespaces, Microsoft.EventHub/namespaces/eventhubs, Microsoft.EventHub/namespaces/eventhubs/authorizationRules, Microsoft.HealthcareApis/workspaces, Microsoft.HealthcareApis/workspaces/fhirservices, SystemAssigned, Microsoft.HealthcareApis/workspaces/iotconnectors, Microsoft.HealthcareApis/workspaces/iotconnectors/fhirdestinations, Microsoft.Authorization/roleAssignments`
