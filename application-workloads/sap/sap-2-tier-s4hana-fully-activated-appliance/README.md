---
description: This template deploys an SAP S/4HANA 2023 Fully Activated Appliance system. 
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

This template offers an alternative path to SAP Cloud Appliance Library (CAL) for quickly deploying a fully configured SAP S/4HANA 2023 system on Azure. This is useful if you prefer more flexibility compared to CAL. 

# Prerequisites

1. **SAP Software**: You must have the SAP S/4HANA 2023 Fully Activated Appliance software. Download the software media from the [SAP Software Centre](https://me.sap.com/softwarecenter).

2. **Storage Account**: A storage account is required to store the SAP software media. Create one using the Azure portal or follow [Create an Azure Storage Account and Blob Container](https://docs.microsoft.com/azure/storage/blobs/storage-quickstart-blobs-portal).

3. **Azure Virtual Network**: A virtual network with at least one subnet is required. Create one using the Azure portal or follow [Create a Virtual Network with two Subnets](https://docs.microsoft.com/azure/virtual-network/quick-create-portal).

4. **Resource Group**: A resource group is needed to deploy the resources. It's recommended to create a new resource group for this deployment to easily delete all resources later.

# Deployment Steps

1. Launch Azure Cloud Shell
Follow the instructions in [Azure Cloud Shell](https://docs.microsoft.com/azure/cloud-shell/overview) to launch Azure Cloud Shell.

2. Deploy the template

Run the following command to deploy the template:

```bash
az group deployment create --name "name of your deployment" --template-uri "URI of the template" --parameters authenticationType="password" adminPasswordOrKey=' password of your VM' subnetId='subnet ID for your VNet'
```

3. Run the SAP S/4HANA 2023 Fully Activated Appliance installation 

Log in to the VM and run the following command. The installation process is sent to the background using the & operator to ensure it continues running even if the session is interrupted:

```bash
./s4install.sh 'https://<storage account name>.blob.core.windows.net/<container name>/*' 'SAS Token' &
```

4. Wait for Installation to Complete 
Go for a long coffee or tea break. The installation process will take a few hours to complete.

5. Access the SAP S/4HANA system 
Once the installation is complete, access the SAP S/4HANA system and have fun! 

# Clean up deployment

Run the following command to delete the resource group and all resources:

```bash
az group delete --name "name of your resource group"
``` 