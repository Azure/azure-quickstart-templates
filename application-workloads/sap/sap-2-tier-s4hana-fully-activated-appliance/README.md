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

This template offers an alternative path to SAP Cloud Appliance Library (CAL) for quickly deploying a fully configured SAP S/4HANA 2023 system on Azure. This is useful if you prefer to have more flexibility over the deployment process. The template is intended for demonstration, training, and development purposes only. 

# Prerequisites

1. **SAP Software**: You must have the SAP S/4HANA 2023 Fully Activated Appliance software. You can download the software media from [SAP Software Centre](https://me.sap.com/softwarecenter). You can find the ZIP files under INSTALLATIONS & UPGRADES => By Alphabetical Index (A-Z) => S => SAP S/4HANA => SAP S/4HANA 2022 => S/4HANA FULLY-ACTIVATED APPLIANCE => SAP S/4HANA 2023 FPS01 FA APPL.

2. **Storage Account**: You must have a storage account to store the SAP software media. You can create a storage account using the Azure portal or use the [Create an Azure Storage Account and Blob Container on Azure](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.storage/storage-blob-container) quickstart template to create a storage account and a blob container.

3. **Azure Virtual Network**: You must have a virtual network with at least one subnet. You can create a virtual network using the Azure portal or use the [Create a Virtual Network with two Subnets](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.network/vnet-two-subnets) quickstart template to create a virtual network with two subnets.

4. **Resource Group**: You must have a resource group to deploy the resources. I would recommend creating a new resource group for this deployment, so that you can easily delete all resources by deleting the resource group. To create the Resource group, type the command:

# Deployment Steps

1. Launch Azure Cloud Shell

2. Deploy the template

Run the following command to deploy the template:

```bash
az group deployment create --name "name of your deployment" --template-uri "URI of the template" --parameters authenticationType="password" adminPasswordOrKey=' password of your VM' subnetId='subnet ID for your VNet'
```

3. Run the SAP S/4HANA 2023 Fully Activated Appliance installation 

Login to the VM and run the following command. Note that I have send the installation process to the background using the `&` operator. This is to ensure that the installation process continues to run even if you disconnect from the Azure Cloud Shell.

```bash
./s4install.sh 'https://<storage account name>.blob.core.windows.net/<container name>/*' 'SAS Token' &
```

4. Go for a long coffee or tea break and wait for the installation to complete. The installation process will take a few hours to complete.

5. Access the SAP S/4HANA system and have fun! 

# Clean up deployment

Run the following command to delete the resource group and all resources:

```bash
az group delete --name "name of your resource group"
``` 



