---
description: The MedTech service is an optional service of the Azure Health Data Services.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: iotconnectors-with-iothub
languages:
- bicep
- json
---
# Deploy the MedTech service including an Azure IoT Hub

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors-with-iothub/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors-with-iothub/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors-with-iothub/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors-with-iothub/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors-with-iothub/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors-with-iothub/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors-with-iothub/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.healthcareapis%2Fworkspaces%2Fiotconnectors-with-iothub%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.healthcareapis%2Fworkspaces%2Fiotconnectors-with-iothub%2Fazuredeploy.json)

## Overview

This template deploys the MedTech service with the required resources and access permissions and includes an Azure IoT Hub. Conforming and valid device and Fast Healthcare Interoperability Resources (FHIR®) destination mappings are also included.

* To learn about this Azure Resource Manager (ARM) template, the resources deployed, and the configured access permissions, see [Receive device messages through Azure IoT Hub](https://learn.microsoft.com/azure/healthcare-apis/iot/device-messages-through-iot-hub)

* To learn about the MedTech service, see [What is MedTech service?](https://learn.microsoft.com/azure/healthcare-apis/iot/overview)

* To learn about device mappings, see [How to configure device mappings](https://learn.microsoft.com/azure/healthcare-apis/iot/how-to-configure-device-mappings)

* To learn about IotJsonPathContentTemplate mappings, see [How to use IotJsonPathContentTemplate mappings](https://learn.microsoft.com/azure/healthcare-apis/iot/how-to-use-iot-jsonpath-content-mappings)

* To learn about FHIR destination mappings, see [How to configure FHIR destination mappings](https://learn.microsoft.com/azure/healthcare-apis/iot/how-to-configure-fhir-mappings)

* To learn about the Azure IoT Hub, see [IoT concepts and Azure IoT Hub](https://learn.microsoft.com/azure/iot-hub/iot-concepts-and-iot-hub)

FHIR® is a registered trademark of Health Level Seven International, registered in the U.S. Trademark Office and is used with their permission.

`Tags: Microsoft.EventHub/namespaces, Microsoft.EventHub/namespaces/eventhubs, Microsoft.EventHub/namespaces/eventhubs/authorizationRules, Microsoft.HealthcareApis/workspaces, Microsoft.HealthcareApis/workspaces/fhirservices, SystemAssigned, Microsoft.HealthcareApis/workspaces/iotconnectors, Microsoft.HealthcareApis/workspaces/iotconnectors/fhirdestinations, Microsoft.Authorization/roleAssignments, Microsoft.Devices/IotHubs`
