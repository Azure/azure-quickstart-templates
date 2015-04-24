# Deploy a highly available MongoDB installation on Ubuntu and CentOS virtual machines

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template creates a multi-server MongoDB deployment on Ubuntu and CentOS virtual machines, and configures the MongoDB installation for high availability using a replica set.
The template also provisions storage accounts, virtual network, availability set, network interfaces, VMs, disks and other infrastructure and runtime resources required by the installation.
In addition, and when explicitly enabled, the template can create one publicly accessible "jumpbox" VM allowing to ssh into the MongoDB nodes for diagnostics or troubleshooting purposes.

The template expects the following parameters:

| Name   | Description | Default Value |
|:--- |:---|:---|
| adminUsername  | Administrator user name used when provisioning virtual machines (which also becomes a system administrator in MongoDB) | |
| adminPassword  | Administrator password used when provisioning virtual machines (which is also a password for the system administrator in MongoDB) | |
| storageAccountName | Unique namespace for the Storage Account where the Virtual Machine's disks will be placed (this name will be used as a prefix to create one or more storage accounts as per t-shirt size) | |
| region | Location where resources will be provisioned | |
| virtualNetworkName | The arbitrary name of the virtual network provisioned for the MongoDB deployment | mongodbVnet |
| subnetName | Subnet name for the virtual network that resources will be provisioned in to | mongodbSubnet |
| addressPrefix | The network address space for the virtual network | 10.0.0.0/16 |
| subnetPrefix | The network address space for the virtual subnet | 10.0.0.0/24 |
| nodeAddressPrefix | The IP address prefix that will be used for constructing a static private IP address for each node in the cluster | 10.0.0.1 |
| jumpbox | The flag allowing to enable or disable provisioning of the jumpbox VM that can be used to access the MongoDB environment | Disabled | 
| tshirtSize | The t-shirt size of the MongoDB deployment (_XSmall_, _Small_, _Medium_, _Large_, _XLarge_, _XXLarge_) | XSmall |
| osFamily | The target OS for the virtual machines running MongoDB (_Ubuntu_ or _CentOS_) | Ubuntu |
| mongodbVersion | The version of the MongoDB packages to be deployed | 3.0.2 |
| replicaSetName | The name of the MongoDB replica set | rs0 |
| replicaSetKey | The shared secret key for the MongoDB replica set (6-1024 characters) |||

Topology
--------

The deployment topology is comprised of a predefined number (as per t-shirt sizing) MongoDB member nodes configured as a replica set, along with the optional
arbiter node. Replica sets are the preferred replication mechanism in MongoDB in small-to-medium installations. However, in a large deployment 
with more than 50 nodes, a master/slave replication is required. 

The following table outlines the deployment topology characteristics for each supported t-shirt size:

| T-Shirt Size | Member Node VM Size | CPU Cores | Memory | Data Disks | Arbiter Node VM Size | # of Members | Arbiter | # of Storage Accounts |
|:--- |:---|:---|:---|:---|:---|:---|:---|:---|
| XSmall | Standard_D1 | 1 | 3.5 GB | 2x100 GB | Standard_A1 | 2 | Yes | 1 |
| Small | Standard_D1 | 1 | 3.5 GB | 2x100 GB | Standard_A1 | 3 | No | 1 |
| Medium | Standard_D2 | 2 | 7 GB | 4x250 GB | Standard_A1 | 4 | Yes | 2 |
| Large | Standard_D2 | 2 | 7 GB | 4x250 GB | Standard_A1 | 8 | Yes | 4 |
| XLarge | Standard_D3 | 4 | 14 GB | 8x500 GB | Standard_A1 | 8 | Yes | 4 |
| XXLarge | Standard_D3 | 4 | 14 GB | 8x500 GB | Standard_A1 | 16 | No | 8 |

An optional single arbiter node is provisioned in addition to the number of members stated above, thus increasing the total number of nodes by 1.
The size of the arbiter node is standardized as _Standard_A1_. Arbiters do not store the data, they vote in elections for primary and require just a bare minimum machine specification to perform their duties.

##Notes, Known Issues & Limitations
- To access the individual MongoDB nodes, you need to use the publicly accessible jumpbox VM and _ssh_ from it into the individual MongoDB instances
- The minimum architecture of a replica set is comprised of 3 members. A typical 3-member replica set can have either 3 members that hold data, or 2 members that hold data and an arbiter
- The deployment script is not yet idempotent and cannot handle updates (although it currently works for initial provisioning only)
- SSH key is not yet implemented and the template currently takes a password for the admin user
- MongoDB version 3.0.0 and above is recommended in order to take advantage of high-scale replica sets offered by this template
- The current version of the MongoDB template is shipped with Ubuntu support only (adding support for CentOS is just a matter of creating an additional installation .sh script)