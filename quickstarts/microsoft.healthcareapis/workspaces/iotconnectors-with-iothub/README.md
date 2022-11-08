---
description: The MedTech service is an optional service of the Azure Health Data Services designed to ingest data from multiple and disparate Internet of Medical Things (IoMT) devices. The MedTech service normalizes, groups, transforms, and persists device health data in the Fast Healthcare Interoperability Resources (FHIR®) service within an Azure Health Data Services workspace.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: iotconnectors-with-iothub
languages:
- json
- bicep
---
# Deploy an Azure Health Data Services MedTech service with an Azure IoT Hub

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors-with-iothub/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors-with-iothub/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors-with-iothub/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors-with-iothub/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors-with-iothub/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors-with-iothub/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors-with-iothub/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.healthcareapis%2Fworkspaces%2Fiotconnectors-with-iothub%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.healthcareapis%2Fworkspaces%2Fiotconnectors-with-iothub%2Fazuredeploy.json)

This template deploys a fully configured instance of the Azure Health Data Services MedTech service and required Azure Health Data resources and an Azure IoT Hub.

## Overview

The MedTech service is an optional service of the Azure Health Data Services designed to ingest health data from multiple and disparate Internet of Medical Things (IoMT) devices. The MedTech service normalizes, groups, transforms, and persists device data in the Fast Healthcare Interoperability Resources (FHIR®) service within an Azure Health Data Services workspace.

To learn more about this quickstart template, the resources deployed, and the configured access permissions, see the MedTech service tutorial [Tutorial: Receive device data through Azure IoT Hub](https://learn.microsoft.com/azure/healthcare-apis/iot/device-data-through-iot-hub)

To learn more about the MedTech service, see [What is MedTech service?](https://learn.microsoft.com/azure/healthcare-apis/iot/iot-connector-overview)

To learn more about IotJsonPathContentTemplate mappings, see [How to use IotJsonPathContentTemplate mappings](https://learn.microsoft.com/azure/healthcare-apis/iot/how-to-use-iot-jsonpath-content-mappings)

To learn more about the Azure IoT Hub, see [IoT concepts and Azure IoT Hub](https://learn.microsoft.com/azure/iot-hub/iot-concepts-and-iot-hub)

## Deployment steps

You can click the **Deploy to Azure** button at the beginning of this document to deploy an instance of this quickstart template using the Azure portal.

While in the final configuration stage within the Azure portal, you will:

* Choose a **basename** for your resources - **Required**.

* Choose the Azure region **location**  which can be the same region as the resource group or a different region than the resource group) where your resources will be deployed - **Required**.

* Choose the **fhirContributorPrincipalId** which is the Azure AD user object ID that you would like to provide FHIR Data Contributor access to for viewing data on your FHIR service - **Optional**.

* Leave the **Device Mapping** and **Destination Mapping** options at their defaults.

**NOTE** - If you do not choose to use the **fhirContributorPrincipalId** option, clear the field of any entries. To learn more about how to acquire an Azure AD user object ID, see [Find the user object ID](https://learn.microsoft.com/partner-center/find-ids-and-domain-names#find-the-user-object-id).

All other parameters for deployment are automatically configured for you.

FHIR® is a registered trademark of Health Level Seven International, registered in the U.S. Trademark Office and is used with their permission.

`Tags: Microsoft.EventHub/namespaces, Microsoft.EventHub/namespaces/eventhubs, Microsoft.EventHub/namespaces/eventhubs/authorizationRules, Microsoft.HealthcareApis/workspaces, Microsoft.HealthcareApis/workspaces/fhirservices, SystemAssigned, Microsoft.HealthcareApis/workspaces/iotconnectors, Microsoft.HealthcareApis/workspaces/iotconnectors/fhirdestinations, Microsoft.Authorization/roleAssignments, Microsoft.Devices/IotHubs`
