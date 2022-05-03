# VNS3 cloud networking appliance for security, connectivity and federation in the clouds

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/cohesive/cohesive-vns3-free-try-now/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/cohesive/cohesive-vns3-free-try-now/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/cohesive/cohesive-vns3-free-try-now/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/cohesive/cohesive-vns3-free-try-now/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/cohesive/cohesive-vns3-free-try-now/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/cohesive/cohesive-vns3-free-try-now/CredScanResult.svg)


[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fcohesive%2Fcohesive-vns3-free-try-now%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fcohesive%2Fcohesive-vns3-free-try-now%2Fazuredeploy.json)

### Introduction
This Quickstart automates the process of deploying a Cohesive Networks VNS3 overlay network in Azure.

It’s intended for users who are interested in a generalised method for encrypting all data in motion between Azure virtual machines, connecting Azure VNETs securely to other networks, and securing traffic with firewalling and network function virtualisation. VNS3 allows you to meet compliance requirements, attest to data security, and manage your cloud deployments. The VNS3 overlay federates resources for multi-region, hybrid cloud and multi-cloud deployments.

### About VNS3
VNS3 is a software only virtual appliance that provides the combined features and functions of a Security Appliance, Application Delivery Controller, and Unified Threat Management device at the cloud application edge.
**Key benefits**;
+ On top of cloud networking
+ Always on end to end encryption
+ Federate data centres, cloud regions, cloud providers, and/or containers, creating one unified address space
+ Attestable control over encryption keys
+ Meshed network manageable at scale
+ Reliable HA in the Cloud
+ Isolation of sensitive applications (fast low cost Network Segmentation)
+ Segmentation within applications
+ Analysis of all data in motion to through and across the cloud
+ Multicast in the cloud

**Key network functions are**; virtual router, switch, firewall, vpn concentrator, multicast re-distributor, with plugins for WAF, NIDS, Caching, Proxy Load Balancers and other Layer 4 thru 7 network functions.

VNS3 doesn't require new knowledge or training to implement, so you can integrate with existing network equipment.

### Cost and licenses
You are responsible for the cost of the Azure services used while running this Quickstart. There is no additional cost from Cohesive Networks for using the Quickstart.
If you require a larger trial license or a license for production use, please email sales@cohesive.net

### Support
If you require technical assistance please email support@cohesive.net

## Quickstart Template
Dynamically launches and configures an overlay network in an Azure VNET.  This template deploys a VNS3 Free Edition into it's own VNET where it creates a multi-client overlay network between multiple hosts, either Windows or Ubuntu.

The template also provisions storage accounts, virtual network, network interfaces, VMs, disks, network security groups and other infrastructure and runtime resources required by the installation.

### This is an overview of the solution

The following resources are deployed as part of the solution:

A VNS3 Free Editon controller

Upto 5 Windows Datacentre 2019 or Ubuntu 18.04.0-LTS virtual machines

VNET, Subnets, NSG's, NIC & PIP's

Once the controller and hosts are deployed a custom script downloads, deploys and configures the overlay network. 

### Prerequisites

You will need an active Azure Subscription

Before you launch the template please accept the Azure Marketplace terms via Azure CLI or Powershell.

Powershell

Get-AzMarketplaceTerms -Publisher "cohesive" -Product "cohesive-vns3-5_0_x" -Name "cohesive-vns3-5_0_x-free" | Set-AzMarketplaceTerms -Accept

### Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

### Connect

Once the deployment is complete, you can access the VNS3 Controller Web UI by navigating to the public IP on port 8000. 

**The username is**: vnscubed

**The password is**: <vmname>-<private-ip> (you will be promted to change the password at initial login)

	https://[PublicIP]:8000

### Management

For comprehesive documentation please visit our website https://docs.cohesive.net 

`Tags: VPN, HA, Multicast, Network Traffic Analysis, Network Visibility, Federation, Security, Isolation, Segmentation, Firewall, NIDS, WAF, Load-balancer, multi-cloud, hybrid, UTM, overlay, NAT, NAT Gateway, Address Overlap, awesome`
