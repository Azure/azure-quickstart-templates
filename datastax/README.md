# Important Note

For the most up to date version of this template, please do not use this repo. Instead go [here](https://github.com/DSPN/azure-resource-manager-dse).  We strongly encourage use of the latest version as it incorporates bug fixes and is more flexible.

# Deploying this DataStax ARM Template

This template deploys a DataStax Enterprise (DSE) cluster to Azure running on Ubuntu virtual machines in a single datacenter.  The template can provision a cluster from 1 to 40 nodes.  Creating a greater number of nodes may cause issues with storage account I/O contention.

The template also provisions a storage account, virtual network and public IP addresses required by the installation.  The template will deploy to the location that the resourceGroup it is part of is located in.

The template expects the following parameters:

| Name   | Description |
|:--- |:---|
| nodeCount | Number of virtual machines to provision for the cluster |
| vmSize | Size of virtual machine to provision for the cluster |
| adminUsername  | Admin user name for the virtual machines |
| adminPassword  | Admin password for the virtual machines |

Once the Azure VMs, virtual network and storage are setup, the template installs Java and DSE on the nodes.  It also configures them.  These nodes are assigned both private and public dynamic IP addresses.

The template also sets up a node to run DataStax OpsCenter.  The script opscenter.sh installs OpsCenter and connects to the cluster by calling the OpsCenter REST API.

On completion, OpsCenter will be accessible on port 8888 of the public IP address of the OpsCenter node.
