---
description: The MedTech service is one of the Azure Health Data Services designed to ingest device data from multiple devices, transform the device data into FHIR Observations, which are then persisted in the Azure Health Data Services FHIR service.
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

> [!NOTE]
> [Fast Healthcare Interoperability Resources (FHIR®)](https://www.hl7.org/fhir/) is an open healthcare specification.

This template deploys the MedTech service with the required resources and access permissions and includes an Azure IoT Hub for device creation/management and device message routing. Conforming and valid device and FHIR destination mappings are also included.

* To learn about this Azure Resource Manager (ARM) template, the resources deployed, and the configured access permissions, see [Receive device messages through Azure IoT Hub](https://learn.microsoft.com/azure/healthcare-apis/iot/device-messages-through-iot-hub).

* To learn about the MedTech service, see [What is MedTech service?](https://learn.microsoft.com/azure/healthcare-apis/iot/overview)

* To learn about the MedTech service device data processing stages, see [Overview of the MedTech service device data processing stages](https://learn.microsoft.com/azure/healthcare-apis/iot/overview-of-device-data-processing-stages).

* To learn how to use the MedTech service Mapping debugger, see [How to use the MedTech service Mapping debugger](https://learn.microsoft.com/azure/healthcare-apis/iot/how-to-use-mapping-debugger).

* For an overview of the MedTech service device mapping, see [Overview of the MedTech service device mapping](https://learn.microsoft.com/azure/healthcare-apis/iot/overview-of-device-mapping).

* To learn about IotJsonPathContent mappings, see [How to use IotJsonPathContent mappings](https://learn.microsoft.com/azure/healthcare-apis/iot/how-to-use-iotjsonpathcontent-mappings).

* For an overview of the MedTech service FHIR destination mapping, see [Overview of the MedTech service FHIR destination mapping](https://learn.microsoft.com/azure/healthcare-apis/iot/overview-of-fhir-destination-mapping).

* To learn about the Azure IoT Hub, see [IoT concepts and Azure IoT Hub](https://learn.microsoft.com/azure/iot-hub/iot-concepts-and-iot-hub).

* To learn about Azure IoT Hub message routing, see [Use IoT Hub message routing to send device-to-cloud messages to different endpoints](https://learn.microsoft.com/azure/iot-hub/iot-hub-devguide-messages-d2c).

FHIR® is a registered trademark of Health Level Seven International, registered in the U.S. Trademark Office and is used with their permission.

`Tags: Microsoft.EventHub/namespaces, Microsoft.EventHub/namespaces/eventhubs, Microsoft.EventHub/namespaces/eventhubs/authorizationRules, Microsoft.HealthcareApis/workspaces, Microsoft.HealthcareApis/workspaces/fhirservices, SystemAssigned, Microsoft.HealthcareApis/workspaces/iotconnectors, Microsoft.HealthcareApis/workspaces/iotconnectors/fhirdestinations, Microsoft.Authorization/roleAssignments, Microsoft.Devices/IotHubs`
