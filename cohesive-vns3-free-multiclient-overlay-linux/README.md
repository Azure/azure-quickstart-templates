# VNS3 Application Security Controller for Public and Private Cloud

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F100-blank-template%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F100-blank-template%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

`Tags: VPN, HA, Multicast`

## VNS3 Application Security Controller for Public and Private Cloud

### Introduction
This Quickstart provides step-by-step instructions for deploying a Cohesive Networks VNS3 overlay network in Azure.
It’s intended for users who are interested in a generalised method for encrypting all data in motion between Azure virtual machines, connecting Azure VNET’s securely to other networks, and securing traffic with firewalling and network function virtualisation. VNS3 allows you to meet compliance requirements, attest to data security, and manage your cloud deployments. The VNS3 overlay also enables multicast in the cloud, hybrid clouds and multi-cloud deployments.

### About VNS3
VNS3 is a software only virtual appliance that provides the combined features and functions of a Security Appliance, Application Delivery Controller, and Unified Threat Management device at the cloud application edge.
Key benefits;
-On top of cloud networking
-Always on end to end encryption
-Federate data centres, cloud regions, cloud providers, and/or containers, creating one unified address space
-Attestable control over encryption keys
-Meshed network manageable at scale
-Reliable HA in the Cloud
-Isolation of sensitive applications (fast low cost Network Segmentation)
-Segmentation within applications
-Analysis of all data in motion to through and across the cloud
Key network functions are; virtual router, switch, firewall, vpn concentrator, multicast re-distributor, with plugins for WAF, NIDS, Caching, Proxy Load Balancers and other Layer 4 thru 7 network functions.
VNS3 doesn't require new knowledge or training to implement, so you can integrate with existing network equipment.

### Cost and licenses
You are responsible for the cost of the Azure services used while running this Quickstart. There is no additional cost from Cohesive Networks for using the Quickstart.
If you require a larger trial license or a license for production use, please email Sales@cohesive.net

### Support
If you require technical assistance please email support@cohesive.net

## Quickstart Template
Dynamically launch and configure your overlay network in minutes using the REST API or web-based UI.  This template deploys a VNS3 Free Edition into it's own VNET where it creates a multi-client overlay network between multiple Linux hosts.
The template also provisions storage accounts, virtual network, network interfaces, VMs, disks, network security groups and other infrastructure and runtime resources required by the installation.

The template expects the following parameters:

| Name   | Description | Default Value |
|:--- |:---|:---|
| adminUsername  | Administrator username for VNS3 (required but not used) | {No Default} |
| adminPassword  | Administrator password for VNS3 (required but not used) | {No Default} |
| adminUsernameUbuntu | Administrator username for Ubuntu VM | {No Default} |
| adminPasswordUbuntu | Administrator password for Ubuntu VM | {No Default} |
| numberOfInstances| VMs to deploy, max 5 as free edition only supports 5 clientpacks | 3 |
| vmSize | The size of the VMs deployed in the overlay network (Defaults to Standard_D1_v2) | Standard_D1_v2 |
| vmImage | The OS VM Image (defaults to Ubuntu 16.04.0-LTS) | 16.04.0-LTS |


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

You will need an active Azure Subscription

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

#### Connect

Once the deployment is complete, you can access the VNS3 Controller Web UI by navigating to the public IP on port 8000. 

The username is: vnscubed
The password is: vnscubed (you will be prompted to change these on initial login)

	https://[PublicIP]:8000

#### Management

How to manage the solution

## Notes

Solution notes