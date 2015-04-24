# Install a Datastax cluster on Ubuntu Virtual Machines using Custom Script Linux Extension

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys a Datastax cluster on the Ubuntu virtual machines. This template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.

The example expects the following parameters:

| Name   | Description    |
|:--- |:---|
| region | Region name where the corresponding Azure artifacts will be created |
| storageAccountPrefix  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed (multiple storage accounts are created with this template using this value as a prefix for the storage account name) |
| dnsName | DNS subnet name for operations center public IP address |
| virtualNetworkName | Name of the Virtual Network that is created and that resources will be deployed in to |
| adminUsername  | Admin user name for the Virtual Machines  |
| adminPassword  | Admin password for the Virtual Machine  |
| opsCenterAdminPassword | Datastax Operations Center Admin User Password |
| clusterName | The name of the new cluster that is provisioned with the deployment |

Topology
--------

This template deploys a configurable number of cluster nodes of a configurable size.  The cluster nodes are internal and only accessable on the internal virtual network.  The Datastax operatinos manager is exposed on a public IP address that you can access through a browser on port :8888 as well as SSH on the standard port.

##Known Issues and Limitations
- The template does not currently configure SSL on Datastax Operations Center virtual machine
- The template uses username/password for provisioning cluster nodes in the cluster, and would ideally use an SSH key
- The template deploys cassandra data nodes configured to use ephemeral storage and attaches a data disk that can be used for data backups in the event of a cluster failure resulting in the loss of the data on the ephemeral disks.
