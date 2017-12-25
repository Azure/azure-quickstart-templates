# Deploy a TiDB cluster on CentOS virtual machines

This template deploys a TiDB cluster on the CentOS virtual machines. This template also provisions a storage account, virtual network, network security groups, availability sets, load balancer, public IP addresses and network interfaces required by the installation. The template also creates 1 publicly accessible VM acting as a "monitor server" and "jumpbox" allowing to ssh into the PD/TiKV/TiDB nodes for diagnostics or troubleshooting purposes. In addition, and created a load balancer for TiDB servers so that users can connect to the database through it.

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

## TiDB architecture
To better understand TiDB’s features, you need to understand the TiDB architecture.

![image alt text](images/tidb-architecture.png)

The TiDB cluster has three components: the TiDB server, the PD server, and the TiKV server. More detailed information can be found [here](https://github.com/pingcap).

