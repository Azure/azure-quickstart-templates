# Create Virtual Machine Scale Set using SR-IOV enabled Azure HPC VMs


This will deploy a [Virtual Machine Scale Set (VMSS)](#https://docs.microsoft.com/azure/virtual-machine-scale-sets/overview) using the SR-IOV enabled Azure VM types. 

Click on the following **Deploy to Azure** link to start your deployment.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fcreate-hpc-vmss-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>

## Input Fields

The above link opens up a template form with the following input fields:

- **Azure Subscription** - Subscription for VMSS deployment.
- **Resource Group** - Resource group under for VMSS. New resource group can be created using the "Create New" link.
- **Location** - VMSS Location.
- **VM SKU** - VM SKU type (Only SR-IOV enabled SKU types are included in the list).
- **Compute Node Image** - OS image for VMSS. Select the "-HPC" flavor for an [optimized HPC image](https://techcommunity.microsoft.com/t5/Azure-Compute/CentOS-HPC-VM-Image-for-SR-IOV-enabled-Azure-HPC-VMs/ba-p/665557).
- **Instance Count** - Number of VMs in the scale set.
- **Username** - Username for VMs.
- **Password** - Password for VMs.
- **RSA Public Key** - RSA Public Key for "ssh"-ing into the head node.

## Cluster Architecture

With this deployment, a head node and a VMSS are created.

### Head Node

The head node can be identified as "`<vmss-name>-hd"`. The RSA Public Key is added to the `.ssh/authorized_keys` of the head node.

### Home Folder

The `\home` folder is mounted over NFS and is hosted by the head node. Review `\etc\exports` for more details.

### Compute Nodes

Compute nodes are the actual VMSS. Run the `generateHostFile` script under `\home\<user>\scripts` folder to generate a list of compute nodes that are part of this VMSS. The hostfile will be generated under `\home\<user>\scripts`.

*Note*: Please review [`hn-setup.sh`](hn-setup.sh) and [`cn-setup.sh`](cn-setup.sh) for more details on how the head node and compute nodes are configured.

## SKU Availability and Locations

Please note that these are specialized SKU types and are not available in all locations. Please refer to [Virtual Machine Availability by Regions](https://azure.microsoft.com/global-infrastructure/services/?products=virtual-machines) to decide on the target location for your deployment.

Before deployment, make sure you have sufficient vCPU quota for the selected SKU in the target location. Please refer to [Quota Increase Requests](https://docs.microsoft.com/azure/azure-supportability/resource-manager-core-quotas-request) for more details on quota requests.
