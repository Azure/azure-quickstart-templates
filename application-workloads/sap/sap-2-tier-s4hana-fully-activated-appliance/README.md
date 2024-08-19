---
description: This template deploy a simplified version of the **SAP S/4HANA 2023 Fully Activated Appliance**. 
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: sap-2-tier-s4hana-fully-activated-appliance
languages:
- bicep
- json
---
# SAP NetWeaver 2-tier S/4HANA 2023 Fully Activated Appliance

This template offers an alternative path to SAP Cloud Appliance Library (CAL) for quickly deploying a fully configured SAP S/4HANA 2023 system on Azure. The template is intended for demonstration, training, and development purposes. 

# Prerequisites

1. **SAP Software**: You must have the SAP S/4HANA 2023 Fully Activated Appliance software. You can download the software media from [SAP Software Centre](https://me.sap.com/softwarecenter). You can find the ZIP files under INSTALLATIONS & UPGRADES => By Alphabetical Index (A-Z) => S => SAP S/4HANA => SAP S/4HANA 2022 => S/4HANA FULLY-ACTIVATED APPLIANCE => SAP S/4HANA 2023 FPS01 FA APPL.

2. **Storage Account**: You must have a storage account to store the SAP software media. You can create a storage account using the Azure portal or use the [Create an Azure Storage Account and Blob Container on Azure](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.storage/storage-blob-container) quickstart template to create a storage account and a blob container.

3. **Azure Virtual Network**: You must have a virtual network with at least one subnet. You can create a virtual network using the Azure portal or use the [Create a Virtual Network with two Subnets](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.network/vnet-two-subnets) quickstart template to create a virtual network with two subnets.

4. **User managed identity**: You must have a user managed identity that has . You can create a user managed identity using the Azure portal or the Azure CLI.






