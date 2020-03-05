# Virtual Network NAT

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/PublicLastTestDate.svg" />&nbsp;
    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/PublicDeployment.svg" />&nbsp;

  <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/FairfaxLastTestDate.svg" />&nbsp;
    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/FairfaxDeployment.svg" />&nbsp;
    
  <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/BestPracticeResult.svg" />&nbsp;
    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/CredScanResult.svg" />&nbsp;
    
    
  <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F100-blank-template%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
    </a>
    <a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F100-blank-template%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
    </a>


This template deploys a **NAT gateway** and supporting resources.

## Overview and Deployed resources

This template is a resource manager implementation of a quickstart for deploying a NAT gateway.  A Ubuntu virtual machine is deployed to the subnet that is associated with the NAT gateway.

> [!IMPORTANT]
>Virtual Network NAT is available as public preview at this time. Currently it's only available in a limited set of [regions](https://docs.microsoft.com/azure/virtual-network/nat-overview#region-availability). This preview is provided without a service level agreement and isn't recommended for production workloads. Certain features may not be supported or may have constrained capabilities. See the [Supplemental Terms of Use for Microsoft Azure Previews](https://azure.microsoft.com/support/legal/preview-supplemental-terms) for details.

Subscriptions must be registered to allow participation in the Public Preview.  Participation requires a two-step process and instructions are provided below for Azure CLI and Azure PowerShell.  The activation may take several minutes to complete.

### Azure CLI

1. Register subscription for Public Preview

    ```azurecli-interactive
      az feature register --namespace Microsoft.Network --name AllowNatGateway
    ```

2. Activate registration

    ```azurecli-interactive
      az provider register --namespace Microsoft.Network
    ```

### Azure PowerShell

1. Register subscription for Public Preview

    ```azurepowershell-interactive
      Register-AzProviderFeature -ProviderNamespace Microsoft.Network -FeatureName AllowNatGateway
    ```

2. Activate registration

    ```azurepowershell-interactive
      Register-AzResourceProvider -ProviderNamespace Microsoft.Network


For more information on **Virtual Network NAT** service and **NAT gateway** see:

* [What is Virtual Network NAT (Public Preview)?](https://docs.microsoft.com/azure/virtual-network/nat-overview)

* [Designing virtual networks with NAT gateway resources (Public Preview)](https://docs.microsoft.com/azure/virtual-network/nat-gateway-resource)

The following resources are deployed as part of the solution

### Microsoft.Network

Description

+ **networkingSecurityGroups**: Network security group for virtual machine.
  + **securityrules**: NSG rule to open port 22 to virtual machine.
+ **publicIPAddresses**: Public IP address for NAT gateway and virtual machine.
+ **publicIPPrefixes**: Public IP prefix for NAT gateway.
+ **natGateways**: NAT gateway resource
+ **virtualNetworks**: Virtual network for NAT gateway and virtual machine.
  + **subnets**: Subnet for virtual network for NAT gateway and virtual machine.
+ **networkinterfaces**: Network interface for virtual machine

### Microsoft.Compute

Description

+ **virtualMachines**: Virtual machine for solution

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

### Connect

Retrieve public IP of virtual machine after deployment and SSH to virtual machine.

`Tags: virtual-network, nat, nat-gateway`
