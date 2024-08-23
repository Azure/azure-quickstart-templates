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

Explore the latest and greatest features of SAP S/4HANA 2023 with this fully activated appliance on Azure! This template deploys a fully configured SAP S/4HANA 2023 system on Azure. You can find more information about this type of deployment method in this excellent [SAP blog post by Mahesh Sardesai](https://community.sap.com/t5/enterprise-resource-planning-blogs-by-sap/s-4hana-2022-fps1-fully-activated-appliance-standard-installation/ba-p/13547947).

## Prerequisites

1. **Azure Virtual Network**: A virtual network with at least one subnet is required. Create one using the Azure portal or follow [Create a Virtual Network with two Subnets](https://docs.microsoft.com/azure/virtual-network/quick-create-portal).

2. **SAP Software**: You must have the SAP S/4HANA 2023 Fully Activated Appliance software. Download the software media from the [SAP Software Centre](https://me.sap.com/softwarecenter). This deployment was build on the SAP software 51057501_1.ZIP, 51057501_2.ZIP, 51057501_3.ZIP, 51057501_4.ZIP and SWPM20SP1880003424.SAR. You might need to adjust the scripts if you are using a different version. 

3. **Resource Group**: A resource group is needed to deploy the resources. It's recommended to create a new resource group for this deployment to easily delete all resources later.

4. **Storage Account**: A storage account is required to store the SAP software media. Create one using the Azure portal or follow [Create an Azure Storage Account and Blob Container](https://docs.microsoft.com/azure/storage/blobs/storage-quickstart-blobs-portal). Upload the SAP software media to a blob container in the storage account. An example of the uploaded files is shown below:

<img src="./images/container.png">

# Deployment Steps

1. Launch Azure Cloud Shell
Follow the instructions in [Azure Cloud Shell](https://docs.microsoft.com/azure/cloud-shell/overview) to launch Azure Cloud Shell.

2. Deploy the template

Run the following command to deploy the template:

```bash
az group deployment create --name "name of your deployment" --template-uri "URI of the template" --parameters authenticationType="password" adminPasswordOrKey=' password of your VM' subnetId='subnet ID for your VNet'
```

3. Run the SAP S/4HANA 2023 Fully Activated Appliance installation 

Log in to the VM and run the following command. Run this command in a jump server to ensure that the installation process is not interrupted. You can set up a managed system identity or use a temporary storage account SAS token to download the SAP software.  

```bash
./s4install.sh 'https://<storage account name>.blob.core.windows.net/<container name>/' 'SAS Token' 
```

or 

```bash
./s4install.sh 'https://<storage account name>.blob.core.windows.net/<container name>/'
```

4. Wait for Installation to Complete 
Go for a long coffee or tea break. The installation process typically takes around 4 hours to complete from start to finish.

5. Access the SAP S/4HANA system 
Once the installation is complete, access the SAP S/4HANA system and have fun! 

# Performance Considerations
A number of factors can affect the performance of the SAP S/4HANA system. The following are some of the key factors to consider:

* This template deploys a Standard_E16-4ds_v5 VM for the SAP S/4HANA system. You can adjust the VM size based on your requirements. 
* The storage is a Azure Premium SSD disk v2 without any LVM. You can adjust the disk size based on your requirements. 
* This template is design for a proof of concept or training environment. For production deployments of your SAP S/4HANA system, it is recommended to use [Azure Centre for SAP Solutions](https://learn.microsoft.com/en-us/azure/sap/center-sap-solutions/overview) or the [SAP on Azure Deployment Automation Framework](https://learn.microsoft.com/en-us/azure/sap/center-sap-solutions/overview).

# Clean up deployment

Run the following command to delete the resource group and all resources:

```bash
az group delete --name "name of your resource group"
``` 
