---
description: This template creates a Microsoft Defender for IoT Firmware Analysis workspace.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: firmwareanalysis-create-workspace
languages:
- bicep
- json
---

# Create a Firmware Analysis Workspace

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.iotfirmwaredefense/firmwareanalysisstTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.iotfirmwaredefense/firmwareanalysis-create-workspace/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.iotfirmwaredefense/firmwareanalysis-create-workspace/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.netfirmwaredefense/firmwareanalysis-create-workspace/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.iotfirmwaredefense/firmwareanalysis-create-workspace/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.iotfirmwaredefensereate-workspace/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.iotfirmwaredefense/firmwareanalysis-create-workspace/BicepVersion.svgure)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templatests%2Fmicrosoft.iotfirmwaredefense%2Ffirmwareanalysis-create-workspace%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Firmwaredefense%2Ffirmwareanalysis-create-workspace%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.iotfirmwaredefense%2Ffirmwareanalysis-createuredeploy.json)

This template deploys a **Firmware Analysis workspace**. The workspace enables you to upload and analyze IoT/OT device firmware for vulnerabilities and security issues.

## Sample overview and deployed resources

This solution provisions a single resource:

### Microsoft.IoTFirmwareDefense

Provides the Firmware Analysis capability.

- **workspaces**: Creates a workspace for firmware analysis.

## Prerequisites

- An active Azure subscription.
- Azure CLI (v2.6.0 or later) or Azure PowerShell installed.
- Register the resource provider:
  ```bash
  az provider register --namespace Microsoft.IoTFirmwareDefense
