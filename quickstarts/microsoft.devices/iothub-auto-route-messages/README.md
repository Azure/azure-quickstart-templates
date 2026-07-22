---
description: Use this template to deploy an IoT Hub and a storage account. Run an app to send messages to the hub that are routed to storage, then view the results.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: iothub-auto-route-messages
languages:
- bicep
- json
---
# Use ARM template to create IoT Hub, route and view messages

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devices/iothub-auto-route-messages/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devices/iothub-auto-route-messages/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devices/iothub-auto-route-messages/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devices/iothub-auto-route-messages/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devices/iothub-auto-route-messages/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devices/iothub-auto-route-messages/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devices/iothub-auto-route-messages/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devices%2Fiothub-auto-route-messages%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devices%2Fiothub-auto-route-messages%2Fazuredeploy.json)

This template creates an IoT Hub instance and a storage account, and shows how to auto-route messages to storage.

If you are new to Azure IoT Hub, see:

- [Azure IoT Hub service](https://azure.microsoft.com/services/iot-hub/)
- [Azure IoT Hub documentation](https://docs.microsoft.com/azure/iot-hub/)
- [Azure IoT Hub template reference](https://docs.microsoft.com/azure/templates/microsoft.devices/iothub-allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Devices&pageNumber=1&sort=Popular)
- [Microsoft Learn IOT Courses and Modules](https://docs.microsoft.com/learn/browse/?products=azure-iot-central%2Cazure-iot-hub )

If you are new to the template development, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
- [Quickstart: Deploy an Azure IoT Hub and a storage account using an ARM template](https://docs.microsoft.com/azure/iot-hub/horizontal-arm-route-messages)

`Tags: Azure IoT Hub, Iot Hub, Resource Manager, Resource Manager templates, ARM templates, Microsoft.Storage/storageAccounts, Microsoft.Storage/storageAccounts/blobServices/containers, Microsoft.Devices/IotHubs`
