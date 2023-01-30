---
description: The MedTech service is an optional service of the Azure Health Data Services.
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

This template deploys the MedTech service with the required resources and access permissions. Conforming and valid device and Fast Healthcare Interoperability Resources (FHIR®) destination mappings are still required.

* To learn about this Azure Resource Manager (ARM) template, the resources deployed, configured access permissions, and required post-deployment tasks, see [Deploy the MedTech service with an Azure Resource Manager template](https://learn.microsoft.com/azure/healthcare-apis/iot/deploy-new-arm)

* To learn about the MedTech service, see [What is the MedTech service?](https://learn.microsoft.com/azure/healthcare-apis/iot/overview)

* To learn about the MedTech service device message data transformation, see [Understand the MedTech service device message data transformation](https://learn.microsoft.com/azure/healthcare-apis/iot/understand-service)

* To learn about the MedTech service device mappings, see [How to configure device mappings](https://learn.microsoft.com/azure/healthcare-apis/iot/how-to-configure-device-mappings)

* To learn about the MedTech service FHIR destination mappings, see [How to configure FHIR destination mappings](https://learn.microsoft.com/azure/healthcare-apis/iot/how-to-configure-fhir-mappings)

FHIR® is a registered trademark of Health Level Seven International, registered in the U.S. Trademark Office and is used with their permission.

`Tags: Microsoft.EventHub/namespaces, Microsoft.EventHub/namespaces/eventhubs, Microsoft.EventHub/namespaces/eventhubs/authorizationRules, Microsoft.HealthcareApis/workspaces, Microsoft.HealthcareApis/workspaces/fhirservices, SystemAssigned, Microsoft.HealthcareApis/workspaces/iotconnectors, Microsoft.HealthcareApis/workspaces/iotconnectors/fhirdestinations, Microsoft.Authorization/roleAssignments`
