# Install a Datastax cluster on Ubuntu Virtual Machines using Custom Script Linux Extension

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys a Couchbase cluster on the Ubuntu virtual machines. This template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.

The example expects the following parameters:

| Name   | Description    |
|:--- |:---|
| adminUsername  | Admin user name for the Virtual Machines  |
| adminPassword  | Admin password for the Virtual Machines  |
| storageAccountPrefix  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed (multiple storage accounts are created with this template using this value as a prefix for the storage account name) |
| region | Region name where the corresponding Azure artifacts will be created |
| virtualNetworkName | Name of the Virtual Network that is created and that resources will be deployed in to |
| clusterName | The name of the new cluster that is provisioned with the deployment |
| tshirtSize | Higher level definition of a cluster size. It can take Small, Medium and Large values. This value causes cluster sizes with following characteristics. Small: 3xStandard_A2, Medium: 4xStandard_A6, Large: 5xStandard_D14  |
| vmNamePrefix | The prefix for the names of the VMs that will be provisioned |
| cbPackageDownloadBase | The URL base the Couchbase package is downloaded from |
| cbPackage | The Couchbase package name |
| jumpbox | Deploys two VMs, one Ubuntu, one Windows to access the cluster from the Internet |

Topology
--------

This template deploys a configurable number of cluster nodes of a configurable size.  The cluster nodes are internal and only accessible on the internal virtual network.  The cluster can be accessed either through a Ubuntu VM accessible  through SSH (port 22), or a Windows VM through RDP, each having a separate public IP for test purposes only. The assumption for the deployment is, the cluster is going to be provisioned as the back end of a service, and never be exposed to internet directly.

The cluster is deployed to one single availability set to ensure the distribution of VMs accross different update domains (UD) and fault domains (FD). Although Couchbase Server replicates your data across multiple instances, the placement of the replicas is important to align across FDs. It is important to make sure the primary data partition and the replicas are not under the same FD; otherwise, in the case of a failure, it could result in possible data unavailability. So, even though it is possible to specify (thus indirectly influence the distribution of VMs accross UD and FD) the number of FDs and UDs with "PlatformFaultDomainCount" and "PlatformUpdateDomainCount" properties of the availability set, we have chosen not to specify those and let that to the discretion of the administrator.

##Known Issues and Limitations
- The deployment scripts are not currently idempotent and this template should only be used for provisioning a new cluster at the moment.
- http://10.0.0.10:8091 needs to be added to IE "Trusted Sites" list to open the admin tool on the Windows VM deployed in test configuration