---
description: MedTech service is an optional service of the Azure Health Data Services (AHDS) designed to ingest device data from multiple and disparate Internet of Medical Things (IoMT) devices and normalizes, groups, transforms, and persists device health data in the Fast Healthcare Interoperability Resources (FHIR®) service.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: iotconnectors
languages:
- json
- bicep
---
# Deploy an AHDS MedTech service

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.healthcareapis%2Fworkspaces%2Fiotconnectors%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.healthcareapis%2Fworkspaces%2Fiotconnectors%2Fazuredeploy.json)

## Overview

MedTech service is an optional service of the Azure Health Data Services designed to ingest device data from multiple and disparate Internet of Medical Things (IoMT) devices. The MedTech service normalizes, groups, transforms, and persists device data in the Fast Healthcare Interoperability Resources (FHIR®) service.

* To learn more about this Azure Resource Manager (ARM) template, the resources deployed, configured access permissions, and required post-deployment tasks, see [Deploy the MedTech service with an Azure Resource Manager template](https://learn.microsoft.com/azure/healthcare-apis/iot/deploy-02-new-button)

* To learn more about MedTech service, see [What is MedTech service?](https://learn.microsoft.com/azure/healthcare-apis/iot/iot-connector-overview)

* To learn more about device mappings, see [How to configure device mappings](https://learn.microsoft.com/azure/healthcare-apis/iot/how-to-use-device-mappings)

* To learn more about FHIR destination mappings, see [How to configure FHIR destination mappings](https://learn.microsoft.com/azure/healthcare-apis/iot/how-to-use-fhir-mappings)

FHIR® is a registered trademark of Health Level Seven International, registered in the U.S. Trademark Office and is used with their permission.

`Tags: Microsoft.EventHub/namespaces, Microsoft.EventHub/namespaces/eventhubs, Microsoft.EventHub/namespaces/eventhubs/authorizationRules, Microsoft.HealthcareApis/workspaces, Microsoft.HealthcareApis/workspaces/fhirservices, SystemAssigned, Microsoft.HealthcareApis/workspaces/iotconnectors, Microsoft.HealthcareApis/workspaces/iotconnectors/fhirdestinations, Microsoft.Authorization/roleAssignments`
