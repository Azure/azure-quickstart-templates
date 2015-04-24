# Install a Spark cluster on Ubuntu Virtual Machines using Custom Script Linux Extension

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys a Spark cluster on the Ubuntu virtual machines. This template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.
The template also creates 1 publicly accessible VM acting as a "jumpbox" and allowing to ssh into the Spark nodes for diagnostics or troubleshooting purposes.

The example expects the following parameters:

| Name   | Description    |
|:--- |:---|
| storageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed |
| adminUsername  | Admin user name for the Virtual Machines  |
| adminPassword  | Admin password for the Virtual Machine  |
| region | Region name where the corresponding Azure artifacts will be created |
| virtualNetworkName | Name of Virtual Network |
| dataDiskSize | Size of each disk attached to Spark nodes (in GB) |
| subnetName | Name of the Virtual Network subnet |
| addressPrefix | The IP address mask used by the Virtual Network |
| subnetPrefix | The subnet mask used by the Virtual Network subnet |
| sparkVersion | Spark version number to be installed |
| sparkClusterName | Name of the Spark cluster |
| sparkNodeIPAddressPrefix | The IP address prefix that will be used for constructing a static private IP address for Master node in the cluster |
| sparkSlaveNodeIPAddressPrefix | The IP address prefix that will be used for constructing a static private IP address for Slave node in the cluster |
| jumpbox | The flag allowing to enable or disable provisioning of the jumpbox VM that can be used to access the Spark nodes |
| tshirtSize | The t-shirt size of the Spark nodes Slaves or workers can be increased (small, medium, large) |

Topology
--------

The deployment topology is comprised of Master and Slave Instance nodes running in the cluster mode. 
You can access the Web UI portal by using Public IP alloted to the Master node like this PublicMasterIP:8080

NOTE: To access the individual Spark nodes, you need to use the publicly accessible jumpbox VM and ssh from it into the VM instances running Spark.

##Known Issues and Limitations
- The deployment script is not yet idempotent and cannot handle updates (it currently works for initial cluster provisioning only)
- Health monitoring of the Spark instances is not currently enabled
- SSH key is not yet implemented and the template currently takes a password for the admin user
- Spark cluster is current enabled for one master and multi slaves. 
- Spark version 1.2.1 or above is a requirement for the cluster (although the older versions can still be deployed without clustered configuration)
- A static IP address will be assigned to each Spark Master node 10.0.0.10
- A static IP address will be assigned to each Spark Slave node in order to work around the current limitation of not being able to dynamically compose a list of IP addresses from within the template (by default, the first node will be assigned the private IP of 10.0.0.30, the second node - 10.0.0.31, and so on)
