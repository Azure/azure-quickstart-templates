# Safewalk2 platform

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F100-blank-template%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F100-blank-template%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

To deploy this template using the scripts from the root of this repo: (change the folder name below to match the folder name for this sample)

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory 'safewalk2-platform'
```
```bash
azure-group-deploy.sh -a safewalk2-platform -l eastus -u
```
If your sample has artifacts that need to be "staged" for deployment (Configuration Scripts, Nested Templates, DSC Packages) then set the upload switch on the command.
You can optionally specify a storage account to use, if so the storage account must already exist within the subscription.  If you don't want to specify a storage account
one will be created by the script (think of this as "temp" storage for AzureRM) and reused by subsequent deployments.

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory '100-blank-template' -UploadArtifacts 
```
```bash
azure-group-deploy.sh -a 100-blank-template -l eastus -u
```

This template deploys a **Safewalk2 platform**. The **Safewalk2 Platform** is an **Identity Manager and authentication system solution**

`Tags: Safewalk , Altipeak, Authentication, 2Factor, TOTP, OATH2, Identity, Strong, Secure`

## Solution overview and deployed resources

This is an overview of the solution

The following resources are deployed as part of the solution

#### Resource provider 1

Description Resource Provider 1

+ **Resource type 1A**: Description Resource type 1A
+ **Resource type 1B**: Description Resource type 1B
+ **Resource type 1C**: Description Resource type 1C

#### Resource provider 2

Description Resource Provider 2

+ **Resource type 2A**: Description Resource type 2A

#### Resource provider 3

Description Resource Provider 3

+ **Resource type 3A**: Description Resource type 3A
+ **Resource type 3B**: Description Resource type 3B

## Prerequisites

In this chapter we will upload the Safewalk VHD images into an Azure subscription account so we can later use it to deploy Safewalk in Azure using an ARM template.

After the deployment of Safewalk into Azure using the ARM template is complete we will follow a few basic steps to complete the deployment of Safewalk directly on the newly installed Safewalk environment.

Uploading the Safewalk Server and Safewalk Gateway VHD images into Azure¶

The first thing you will need to do before you can deploy Safewalk using the ARM template is to upload the Safewalk Server and Safewalk Gateway VHD images to your Azure subscription by following the steps below:

Download the Safewalk Server and Safewalk Gateway VHD images to your local machine.

Login into the Azure portal (https://portal.azure.com)

If you plan to deploy Safewalk into an existing Resource group select the resource group you would like to use.

If you would like to create a new Resource group for the Safewalk deployment select + New on the portal and type resource group in the search box that appears. Now create the new resource group according to your preferences.

Azure new resource group
Azure new resource group

In the Resource group that will be used to deploy Safewalk you can choose to use an existing blob storage account that is attached to the Resource group or create a new blob Storage account (by selecting the + Add button on the Resource group Overview page and typing Storage account in the search box that appears)

Azure new blob storage account
Azure new blob storage account

In the Resource group that will be used to deploy Safewalk choose the blob Storage account and add a container to upload the VHD images into.

Azure new storage account container
Azure new storage account container

Select the new container and click the Upload button to upload the VHD images of the Safewalk Server and Safewalk Gateway.

After the upload of the images is complete, you should see it listed under the container.

Selecting one of the images will open the blob properties and show you a URL that points to the image that was uploaded.

Copy the URL of the Safewalk Server and Safewalk Gateway VHD images and save it for the Safewalk ARM deployment phase.

Azure VHD images uploaded to container
Azure VHD images uploaded to container

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

#### Connect

How to connect to the solution

#### Management

How to manage the solution

## Notes

Solution notes