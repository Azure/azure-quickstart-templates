# Safewalk2 platform

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsafewalk2-platform%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsafewalk2-platform%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

To deploy this template using the scripts from the root of this repo:

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'westus' -ArtifactsStagingDirectory 'safewalk2-platform' -UploadArtifacts 
```
```bash
azure-group-deploy.sh -a safewalk2-platform -l westus -u
```

This template deploys a **Safewalk2 platform**. The **Safewalk2 Platform** is an **Identity Manager and authentication system solution**

`Tags: Safewalk , Altipeak, Authentication, 2Factor, TOTP, OATH2, Identity, Strong, Secure`

## Solution overview and deployed resources

Safewalk platform is an Identity Management solution with focus on (2FA) Strong authentication

The following resources are deployed as part of the solution

#### Safewalk server instance

The Safewalk server VM is installed inside the LAN subnet. It's recommended to access it using a VPN. If cluster is enabled, 2 VMs will be created in the same availability set (differnt physical machines).

#### Safewalk Gateway

The Gateway VM will be created at the DMZ subnet. It's the the Safewalk frontend for the final user.


## Prerequisites

To get use this Safewalk2 platform you'll need to upload the VM's VHD images to yout storage account.
You can do it using AzCopy storage tool. <a href="http://aka.ms/downloadazcopy" target="_blank">Download and install the latest version of AzCopy</a>

Please replace {dest_container_url} with your information and provide the storage account access {key2}.

```PowerShell
AzCopy /Source:https://safewalkvhd.blob.core.windows.net/images /Dest:{dest_container_url} /SourceKey:fkncsm84fINJHbcoeFmLYORj/h0dzM1kxB4iF/pOnuCLfvLqTRJGkK2oixACn1vZAT046TLyVIpBWfLgS2ddnA== /DestKey:{key2} /S
```

Please contact us at order@altipeak.com in order to buy licenses to get Safewalk ready to use.


### Uploading the Safewalk Server and Safewalk Gateway VHD images

The first thing you will need to do before you can deploy Safewalk using the ARM template is to upload the Safewalk Server and Safewalk Gateway VHD images to your Azure subscription by following the steps below:

Download the Safewalk Server and Safewalk Gateway VHD images to your local machine.

Login into the Azure portal (https://portal.azure.com)

If you plan to deploy Safewalk into an existing Resource group select the resource group you would like to use.

If you would like to create a new Resource group for the Safewalk deployment select + New on the portal and type resource group in the search box that appears. Now create the new resource group according to your preferences.

Azure new resource group

In the Resource group that will be used to deploy Safewalk you can choose to use an existing blob storage account that is attached to the Resource group or create a new blob Storage account (by selecting the + Add button on the Resource group Overview page and typing Storage account in the search box that appears)

Azure new blob storage account

In the Resource group that will be used to deploy Safewalk choose the blob Storage account and add a container to upload the VHD images into.

Azure new storage account container

Select the new container and click the Upload button to upload the VHD images of the Safewalk Server and Safewalk Gateway.

After the upload of the images is complete, you should see it listed under the container.

Selecting one of the images will open the blob properties and show you a URL that points to the image that was uploaded.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

#### Connect

Make a Point-to-Site VPN using the GatewaySubnet of the LAP subnet to get access to the Safewalk servers.

Safewalk servers will be accesible using this url: https://[safewalk_ip]:8443

Safewalk servers are accesible from SSH using the specified credentials.

The Gateway SSH is only accesible from the Safewalk nodes. Only web services are accesible from the Internet.
