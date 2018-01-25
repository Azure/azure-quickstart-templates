# VM Scale Set from a Managed Image connected to an existing Virtual Network and Application Gateway

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-custom-image-existing-vnet-existing-app-gateway%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-custom-image-existing-vnet-existing-app-gateway%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys a VM Scale Set based on a specified custom image (in the form of a Managed Image), connected to an existing subnet in an existing Virtual Network, and adds the instances to a specified existing Application Gateway Backend Pool. This is useful in cases where you might want to deploy multiple VM Scale Sets in the same Virtual Network, as well as configure the Application Gateway outside of this template, such as through the portal, which provides a more reliable experience for things like adding HTTPS listeners.

`Tags: VM Scale Set, VMSS, Managed Disks, Managed Images, Custom Image`

## Prerequisites

To deploy this template, you will need:
 * An existing Managed Image ([about Managed Images](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-capture-image-resource))
 * An existing Virtual Network and subnet located in another Resource Group
 * An existing Application Gateway and backend pool located in another Resource Group

In the parameters, you will need to take note of:
 * The name of the resource group containing the Managed Image
 * The name of the Managed Image itself
 * The name of the resource group containing the Virtual Network
 * The name of the subnet inside the Virtual Network where the create VM Scale Set will connect to
 * The name of the resource group containing the Application Gateway
 * The name of the backend pool inside the Application Gateway which will be added with instances of the VM Scale SEt

## Deployment steps

You can click the "Deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

#### Connect

To connect to individual instances of the VM Scale Set, utilize a jumpbox VM, that is, another VM that is located

## Notes

The OS of the VM Scale Set will follow whatever is defined in the custom image.
