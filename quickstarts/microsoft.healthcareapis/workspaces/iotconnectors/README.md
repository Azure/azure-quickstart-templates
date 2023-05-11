---
description: The MedTech service is one of the Azure Health Data Services designed to ingest device data from multiple devices, transform the device data into FHIR Observations, which are then persisted in the Azure Health Data Services FHIR service.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: iotconnectors
languages:
- bicep
- json
---
# Deploy the MedTech service

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

> [!NOTE]
> [Fast Healthcare Interoperability Resources (FHIR®)](https://www.hl7.org/fhir/) is an open healthcare specification.

This template deploys the MedTech service with the required resources and access permissions. Conforming and valid device and FHIR destination mappings are still required.

* To learn about this Azure Resource Manager (ARM) template, the resources deployed, configured access permissions, and required post-deployment tasks, see [Deploy the MedTech service with an Azure Resource Manager template](https://learn.microsoft.com/azure/healthcare-apis/iot/deploy-new-arm).

* To learn about the MedTech service, see [What is the MedTech service?](https://learn.microsoft.com/azure/healthcare-apis/iot/overview)

* To learn about the MedTech service device data processing stages, see [Overview of the MedTech service device data processing stages](https://learn.microsoft.com/azure/healthcare-apis/iot/overview-of-device-data-processing-stages).

* To learn how to use the MedTech service Mapping debugger, see [How to use the MedTech service Mapping debugger](https://learn.microsoft.com/azure/healthcare-apis/iot/how-to-use-mapping-debugger).

* For an overview of the MedTech service device mapping, see [Overview of the MedTech service device mapping](https://learn.microsoft.com/azure/healthcare-apis/iot/overview-of-device-mapping).

* For an overview of the MedTech service FHIR destination mapping, see [Overview of the MedTech service FHIR destination mapping](https://learn.microsoft.com/azure/healthcare-apis/iot/overview-of-fhir-destination-mapping).

FHIR® is a registered trademark of Health Level Seven International, registered in the U.S. Trademark Office and is used with their permission.

`Tags: Microsoft.EventHub/namespaces, Microsoft.EventHub/namespaces/eventhubs, Microsoft.EventHub/namespaces/eventhubs/authorizationRules, Microsoft.HealthcareApis/workspaces, Microsoft.HealthcareApis/workspaces/fhirservices, SystemAssigned, Microsoft.HealthcareApis/workspaces/iotconnectors, Microsoft.HealthcareApis/workspaces/iotconnectors/fhirdestinations, Microsoft.Authorization/roleAssignments`
