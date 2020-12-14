# SAS 9.4 Visual Analytics/Visual Statistics Quickstart Template for Azure 

**Note:** If you are using the SAS 9.4 Visual Analytics/Visual Statistics Quickstart Template for Azure, be aware that this is a reference architecture and not intended for production use.  The SAS 9.4 VA/VS Quickstart Template for Azure deploys Apache Hadoop.  As stated in our [SAS 9.4 Support for Hadoop policy](https://support.sas.com/en/documentation/third-party-software-reference/9-4/support-for-hadoop.html), SAS does not provide support for the installation or other aspects of the administration and operation of Apache Hadoop.  For support with these issues, please refer to the Apache Hadoop open source community.

This README for SAS 9.4 Visual Analytics (VA)/ Visual Statistics (VS) Quickstart Template for Azure is used to deploy the following SAS Viya products in the Azure cloud:

* SAS Visual Analytics 7.5

* SAS Visual Statistics 7.5

This Quickstart is a reference architecture for users who want to deploy the SAS 9.4 VA/VS  platform using cloud-friendly technologies. By deploying the SAS platform in Azure, you get access to SAS analytics visualization and the ability to create powerful statistical models in an Azure-validated environment. 


For assistance with SAS software, contact  [SAS Technical Support](https://support.sas.com/en/technical-support.html).   When you contact support, you will be required to provide information, such as your SAS site number, company name, email address, and phone number, that identifies you as a licensed SAS software customer. 
## Contents
1. [Overview](#Overview)
    1. [Costs and Licenses](#Costs)
        1. [SAS 9.4 VA/VS server](#compute)
        1. [SAS 9.4M7 Mid-Tier server](#midtier)
        1. [SAS 9.4M7 Metadata clustered server](#metadata)        
1. [Prerequisites](#Prerequisites)
    1. [Create the Blob Shared Access Signature](#create-shared-access-signature)
1. [Best Practices when Deploying SAS 9.4M7 VA/VS on Microsoft Azure](#best_practices) 
1. [Deployment Steps](#Deployment)
    1. [Deploy Using the Azure Portal](#azureportal)
    1. [Deploy Using Mercury Admin Tools](#mercuryadmintools)
1. [Post Deployment Steps](#PostDeployment)
    1. [Accessing Resources in the Deployment](#accessresources)
    1. [Restarting Services](#restartservices)
    1. [Running SAS Management Console (SMC)](#smc)
1. [Troubleshooting](#Troubleshooting)
1. [Appendix A:](#AppendixA)


<a name="Overview"></a>
## Overview

By default, Quickstart deployments enable Transport Layer Security (TLS) for secure communication.

This SAS 9.4 VA/VS Quickstart Template for Azure will take a generic license for SAS 9.4 and deploy SAS into its own network. The deployment creates the network and other infrastructure.  After the deployment process completes, you will have the outputs for the web endpoints for a SAS 9.4 deployment on the recommended virtual machines (VMs). 

When you deploy the Quickstart with default parameters in a massively parallel processing (MPP) environment, the following SAS 9.4 environment is built in the Microsoft Azure cloud, shown in Figure 1.   

![Network Diagram](Azure_9_vavs_quickstart.svg)

Figure 1: Quickstart architecture for SAS 9.4 VA/VS on Azure in an MPP Environment

<a name="Costs"></a>
### Costs and Licenses
You are responsible for the cost of the Azure services used while running this Quickstart deployment. There is no additional cost for using the Quickstart.
You will need a SAS license to launch this Quickstart. Your SAS account team and the SAS Enterprise Excellence Center can advise on the appropriate software licensing and sizing to meet your workload and performance needs.
The SAS 9.4 VA/VS Quickstart Template for Azure creates three instances, including: 
* 1 compute server virtual machine (VM), the SAS VA/VS server
* 1 middle tier VM, the SAS 9.4M7 Mid-Tier server
* 1 metadata server VM, the SAS 9.4M7 Metadata clustered server

<a name="compute"></a>
#### SAS 9.4 VA/VS server
We  recommend that you use at least the memory optimized Standard E16s_v3 VM size.

Here are some recommended example VM sizes based on the number of licensed cores:

| Licensed Cores  | Virtual Machine| SKU	Memory(RAM) | Maximum Dataset Size | Cache Size |
| ------------- | ------------- | ------------- | ------------- | ------------- |
|4  | Standard_E8s_v3   | 64 GB  | 20-40 GB	  |128 GB  |
| 8 | Standard_E16s_v3  | 128 GB  |20-40 GB	  |256 GB  |
| 16  | Standard_E32s_v3| 256 GB  | 90-170 GB |512 GB  |

<a name="midtier"></a>
#### SAS 9.4M7 Mid-Tier server
We  recommend that you use one or two of the memory optimized Standard E16s_v3 VM size at least.

<a name="metadata"></a>
#### SAS 9.4M7 Metadata clustered server
We  recommend that you use one or three of the memory optimized Standard E16s_v3 VM size at least.

<a name="Prerequisites"></a>
## Prerequisites

Before deploying SAS 9.4 VA/VS Quickstart Template for Azure, you must have the following:
* A Microsoft Azure account if you do not already have one. Request an Azure account at ["CIS Cloud Services"](http://sww.sas.com/sites/it/cloud-services/).
* A SAS Software Order Confirmation Email that contains the following supported Quickstart products:

 		SAS Visual Analytics 7.5 on Linux
		SAS Visual Statistics 7.5 on Linux
        
* A SAS 9.4M7 VA/VS software order with the depot uploaded to Azure Blob Storage.
* An Azure blob Shared Access Signature (SAS). See ["Create the Blob Shared Access Signature"](#create-shared-access-signature) for more information. 

**Note:** This is not necessary if you are deploying the SAS 9.4M7 depot that is already uploaded to Azure.
* A response file that you create with the SAS Deployment Wizard.  See ["Recording a SAS Deployment Wizard Response file"](https://go.documentation.sas.com/?cdcId=bicdc&cdcVersion=9.4&docsetId=biig&docsetTarget=n05023intelplatform00install.htm&locale=en#n05026intelplatform00install) for more information.
* Sufficient quota of at least 28 Cores, based on four licensed SAS cores in an SMP environment.  In MPP environments, apply this sizing to the CAS workers as well as the CAS controller.

*  Verification that your required SAS 9.4M7 file upload sizes do not exceed the limits of the Application Gateway. For details about limits, see 
["Application Gateway limits."](https://docs.microsoft.com/en-us/azure/azure-subscription-service-limits?toc=%2fazure%2fapplication-gateway%2ftoc.json#application-gateway-limits)
* A resource group that does not already contain a Quickstart deployment. For more information, see ["Resource groups"](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview#resource-groups).

<a name="create-shared-access-signature"></a>
### Create the Blob Shared Access Signature (SAS)
When you run the deployment, you will need the blob Shared Access Signature (SAS) URL as a parameter. 

Before you run the deployment:
1. Upload the entire software depot to Azure Blob Storage.  Follow the Microsoft Azure instructions to 
["Create a Container"](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-portal#create-a-container) and 
["Upload a Block Blob."](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-portal#upload-a-block-blob)

2. Create a Shared Access Signature (SAS) token. Follow these steps to create a Service SAS: 
    * Navigate to the license file blob and select **Generate SAS**, and then click **Generate blob SAS** token and URL.
    * Make a note of the blob SAS URL for use during deployment.
    
For details, see ["Using Shared Access Signatures."](https://docs.microsoft.com/en-us/azure/storage/common/storage-dotnet-shared-access-signature-part-1)

<a name="best_practices"></a>
## Best Practices when Deploying SAS 9.4M7 VA/VS on Microsoft Azure

<a name="Deployment"></a>
## Deployment Steps

<a name="azureportal"></a>
### Deploy Using the Azure Portal

1. Log into the Azure portal [here](https://portal.azure.com/#home).  
2. Navigate to the  [Custom Deployment page](https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fsassoftware%2fazure-quickstart-templates%2fdevelop-sas94m7-VAVS%2fsas-9.4m7-VA%2fazuredeploy.json).
3. Specify the following parameters for your deployment:

|Parameter Name|Value|
|--------------|-----------|
|Subscription|Use the default subscription (recommended) or provide a valid subscription name.|
|Resource group|Click *Create new* (recommended) and provide a name for the new group.|
|Location|Use the default location (recommended).|
|SAS Depot Location|A SAS 9.4m7 VA/VS depot has been uploaded [here](https://azureviya.blob.core.windows.net/94-deployment-data/vavs97/nondist/depot?sp=rl&st=2020-07-28T13:17:43Z&se=2025-07-28T13:17:00Z&sv=2019-12-12&sr=c&sig=01%2B%2BoiLLo4RYhNRlj9kozsS5oVkT9LiUyeCkCIiP%2FwE%3D). Copy and paste that URL into this field.|
|Use a New or Existing Virtual Network?|Use a new network (recommended).|
|Existing Virtual Network Resource Group|Leave blank (recommended).|
|Virtual Network Name|Use the default value (recommended).|
|Operating System Image|Use the default image which is SUSE Enterprise Linux 12 (recommended).|
|Mid-Tier VM Name Base| ???????????|
|Proximity Placement Group Name|Use the default values for all parameters in this range (recommended).|
|SSH Key for VM Access|Cut and paste a public SSH key into this field.|
|Allow management from IP address or CIDR block|Use 149.173.0.0/16 to access the deployment from inside the SAS firewall. To access the deployment from outside the SAS firewall, use the IP address of the machine accessing the deployment, followed by “/32” (for example, 123.456.78.9/32).|
|Deploy Azure Bastion|Use the default (recommended).|
|\_artifacts Location SAS Token|Leave blank.|
|\_artifacts Location|For deployments using the development templates, use this location: [https://raw.githubusercontent.com/sassoftware/azure-quickstart-templates/develop-sas94m7-VAVS/sas-9.4m7-VA/ ](https://raw.githubusercontent.com/sassoftware/azure-quickstart-templates/develop-sas94m7-VAVS/sas-9.4m7-VA/ )|

4. Select *I agree to the terms and conditions stated above* and then select *Purchase*.
The deployment will begin.  Deployments typically take 2-3 hours to complete. 

<a name="mercuryadmintools"></a>
### Deploy Using the Mercury Admin Tools

(content under development:  The mercury-admin tools have not yet been updated for the 9.4m7 deployment.  Also, customer will have the option to use a set of command line tools.)

<a name="PostDeployment"></a>
## Post Deployment Steps

<a name="accessresources"></a>
### Accessing Resources in the Deployment

After a deployment successfully completes, you can check the logs and services status by accessing the various VM instances from the jumpvm. 

1. Obtain the Public IP Address of the jumpvm from the jumpvm’s details: 

   a. Navigate to [https://portal.azure.com/#blade/HubsExtension/BrowseResourceGroups](https://portal.azure.com/#blade/HubsExtension/BrowseResourceGroups) and select the *Resource Group* created by the deployment.
   
   b. Select the *jumpvm* resource from the list of resources in the *Resource Group*. The public IP address is displayed in the *Resource Overview*. 

2. Using the Public IP address, ssh to the jumpvm: 

    ```
   ssh -I <public key pem file> AzureUser@<jumpvm public IP address>
   ```
   
   The jumpvm provides SSH access to the other VMs in the deployment: 
   * SSH access using the AzureUser account 
   ```
   ssh <vm name>
   ```
   For example:
   ```
   ssh midtier-0 
   ```
   * SSH access using the sasinst service account
   ```
   ssh sasinst@<vm name>
   ```
   For example:
   ```
   ssh sasinst@midtier-0 
   ```
   The password for all accounts is set to the default: *Go4thsas*
   
   SAS is installed in the /sas folder on all VMs. 


<a name="restartservices"></a>
### Restarting Services
Some services may not successfully restart when the deployment completes. 

To restart the midtier services, SSH to the midtier-0 VM instance and perform the following steps: 
```
cd /sas/config/Lev1 
./sas.servers stop 
./sas.servers start 
```

<a name="smc"></a>
### Running SAS Management Console (SMC)
The easiest way to run SMC is to connect to the deployment using X11 port forwarding as follows:
```
ssh -X -i <public key pem file> AzureUser@<jumpvm public IP address>
ssh -X <vm name> 
cd /sas/SASHome/SASManagementConsole/9.4 
./sasmc & 
```
For example, to run SMC on the *midtier-0* VM:
```
ssh -X -i <public key pem file> AzureUser@<jumpvm public IP address>
ssh -X midtier-0 
cd /sas/SASHome/SASManagementConsole/9.4 
./sasmc & 
```

<a name="Troubleshooting"></a>
## Troubleshooting

<a name="AppendixA"></a>
## Appendix A: 
