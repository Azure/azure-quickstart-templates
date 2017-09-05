
# Video On-Demand with Wowza, Aspera, & Azure Media Services Azure Partner Quickstart Template
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvod-aspera-wowza-azuremediaservices%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvod-aspera-wowza-azuremediaservices%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

## Solution Template Overview

**Solution Templates** provide customers with a highly automated process to launch enterprise ready first and 3rd party ISV solution stacks on Azure in a pre-production environment. The Solution Template effort is complimentary to the Azure Marketplace test drive program. These fully baked stacks enable customers to quickly stand up a PoC or Piloting environments and also integrate it with their systems and customization.

Customers benefit greatly from solution templates because of the ease with which they can stand up enterprise-grade, fully integrated stacks on Azure. The extensive automation and testing of these solutions will allow them to spin up pre-production environments with minimal manual steps and customization. Most importantly, customers now have the confidence to transition the solution into a fully production-ready environment with confidence.

The **Video On-Demand with Wowza, Aspera, & Azure Media Services Azure Partner Quickstart Template** launches a secure, on-demand, high quality and reliable audio/video streaming solution with Wowza on Azure. Combined with Aspera and Azure Media services, this solution stack will allow users to quickly instantiate a media services stack/platform and bring their custom content and configuration to be streamed. These are intended as pilot solutions and not production-ready.

Please [contact us](azuremarketplace@sysgain.com) if you need further info or support on this solution.

## Licenses & Costs

In its current state, solution templates come with licenses built-in – there may be a BYOL option included in the future. The solution template will be deployed in the Customer’s Azure subscription, and the Customer will incur Azure usage charges associated with running the solution stack.

## Target Audience

The target audience for these solution templates are IT professionals who need to stand-up and/or deploy infrastructure stacks.

## Prerequisites

Azure Subscription - Azure user account with Contributor/Admin Role

Sufficient Quota - At least 10 Cores with DS1 VM Sizes

Aspera Entitlement Key and Customer ID

## Solution Summary
![Solution Summary](https://github.com/sysgain/azurequickstarts/blob/vcherukuri-patch-3/VOD-Aspera-Wowza-AzureMediaServices/Images/wowza.png?raw=true)

The Video On-Demand with Wowza, Aspera, & Azure Media Services Azure Partner Quickstart Template is a Video On-Demand (VOD) Solution Built on Microsoft Azure. It delivers video on-demand streaming from your location to a global audience using Aspera Faspex Technology, Azure Media Services and Wowza Streaming Server. 

VOD systems allow users to select and watch/listen to video or audio content when they choose to, rather than being limited to a specific broadcast time. 

Aspera Faspex On Demand will transfer data up to 100x faster than TCP or FTP. With this offering, a user could transfer a 10GB file in approximately 12 minutes over a 100Mbps internet connection.  Aspera allows customers to quickly move data of any size to any cloud environment over any network at line speed. The solution provides high-speed, robust, secure and resumable file transfers directly to cloud storage environments.

Aspera Faspex On-Demand Hourly provides up to 100 Mbps transfer and delivery platform. Aspera Faspex On-Demand runs as a VM in your account and transfers files from On-premise to Azure blob storage.

Azure Media Services Encoder is used for smooth content delivery across multiple devices, encode all of your content into standard multiple bitrate MP4 files and deliver them dynamically to the latest adaptive bitrate streaming protocols.

Wowza Streaming Engine™ is a robust, customizable media server software that powers reliable streaming of high-quality video and audio to any device, anywhere. Wowza Streaming Engine on Microsoft Azure is ideally suited for streaming of live events, concerts, church services, webinars, and company meetings. 

## Product Architecture

![Product Architecture](https://github.com/sysgain/P2Pimages/blob/P2Pimages/wowza%20p2p%20Architecture.jpg?raw=true)

## Solution contains the following:

The diagram above provides the overall deployment architecture for this solution template.
As a part of deployment, the template launches the following:

- End User Desktop
- Aspera Faspex Server
- Storage Account
- Azure Media Services
- Wowza Streaming Server

### EndUser Desktop

The Desktop runs Windows 2012. The size of VM is Standard A1. Aspera connect Client is installed on the Desktop.

### Aspera Faspex Server

Aspera Faspex is a Linux Centos Machine. The size of VM is Standard DS1. Aspera’s transfer service can move terabytes of data in and out of Azure BLOBs, as well as local storage, up to 100x faster than FTP, while the Aspera Application Platform supports a variety of Aspera or custom client options for desktop, web and mobile transfers.

### Azure Storage Account

The End User transfers the Video files from his Desktop to the Storage Account through the Aspera connect Client. All the video files are saved as BLOBS in a container in the Storage Account. Azure Media Services picks the video files, encodes it into various formats and saves it to another container in the storage account.

### Azure Media Services

Azure Media Services Encoder is used for smooth content delivery across multiple devices, encode all of your content into standard multiple bitrate MP4 files and deliver them dynamically to the latest adaptive bitrate streaming protocols.

### Wowza Streaming Engine Server
Wowza Streaming Engine server is used for streaming of on-demand video over IP networks to desktop, laptop, and tablet computers, mobile devices. Wowza Streaming Engine can stream to multiple types of playback clients and devices simultaneously, including the Adobe Flash player, Microsoft Silverlight player, Apple QuickTime Player and iOS devices.

## Deployment Steps

You can use the “deploy to Azure” button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

The deployment takes about 30 Minutes.

Once it is deployed refer to the user guide to take you to step by step to use the Solution -- [download it here](https://github.com/sysgain/Ignite2016-HandsOnLabs/blob/master/HOL%20Video%20on%20Demand%20Services%20with%20Aspera%20Wowza%20Streaming%20Engine%20and%20Azure%20Media%20Services.pdf).
