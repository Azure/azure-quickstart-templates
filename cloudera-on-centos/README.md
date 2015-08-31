# These templates are currently in testing and will be ready soon. There may be issues deploying this template

# Deploy a Cloudera CDH installation on CentOS virtual machines

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcloudera-on-centos%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>

This template creates a multi-server Cloudera CDH 5.4.x Apache Hadoop deployment on CentOS virtual machines, and configures the CDH installation for either POC or high availability production cluster.
The template also provisions storage accounts, virtual network, availability set, network interfaces, VMs, disks and other infrastructure and runtime resources required by the installation.

The template expects the following parameters:

| Name   | Description | Default Value |
|:--- |:---|:---|
| adminUsername  | Administrator user name used when provisioning virtual machines | testuser |
| adminPassword  | Administrator password used when provisioning virtual machines | Eur32#1e |
| cmUsername | Cloudera Manager username | cmadmin |
| cmPassword | Cloudera Manager password | cmpassword |
| storageAccountPrefix | Unique namespace for the Storage Account where the Virtual Machine's disks will be placed | defaultStorageAccountPrefix |
| numberOfDataNodes | Number of data nodes to provision in the cluster | 3 |
| dnsNamePrefix | Unique public dns name where the Virtual Machines will be exposed | defaultDnsNamePrefix |
| region | Azure data center location where resources will be provisioned |  |
| storageAccountType | The type of the Storage Account to be created | Standard_LRS |
| virtualNetworkName | The name of the virtual network provisioned for the deployment | clouderaVnet |
| subnetName | Subnet name for the virtual network where resources will be provisioned | clouderaSubnet |
| addressPrefix | The network address space for the virtual network | 10.0.0.0/24 |
| subnetPrefix | The network address space for the virtual subnet | 10.0.0.0/24 |
| nodeAddressPrefix | The IP address prefix that will be used for constructing private IP address for each node in the cluster | 10.0.0. |
| tshirtSize | T-shirt size of the Cloudera cluster (Eval, Prod) | Eval |
| vmSize | The size of the VMs deployed in the cluster (Defaults to Standard_DS14) | Standard_DS14 |


Topology
--------

The deployment topology is comprised of a predefined number (as per t-shirt sizing) Cloudera member nodes configured as a cluster, configured using a set number of manager,
name and data nodes. Typical setup for Cloudera uses one manager node and 2 name nodes with as many data nodes are needed for the size that has been choosen ranging from as
few as 3 to thousands of data nodes.  The current template will scale at the highest end to 200 data nodes when using the large t-shirt size.

The following table outlines the deployment topology characteristics for each supported t-shirt size:

| T-Shirt Size | Member Node VM Size | CPU Cores | Memory | Data Disks | # of Manager Node VMs | # of Name Node VMs |
|:--- |:---|:---|:---|:---|:---|:---|:---|
| Eval | Standard_D14 | 16 | 112 GB | 16x1000 GB | 1 | 1 (primary, secondary, cloudera manager) |
| Prod | Standard_D14 | 16 | 112 GB | 16x1000 GB | 3 | 1 primary, 1 standby (HA), 1 cloudera manager |

##Connecting to the cluster
The machines are named according to a specific pattern.  The manager node is named based on parameters and using the.

	[dnsNamePrefix]-mn0.[region].cloudapp.azure.com

If the dnsNamePrefix was clouderatest in the West US region, the machine will be located at:

	clouderatest-mn0.westus.cloudapp.azure.com

The rest of the name nodes and data nodes of the cluster use the same pattern, with -mn and -dn extensions followed by their number.  For example:

        clouderatest-mn0.westus.cloudapp.azure.com
	clouderatest-mn1.westus.cloudapp.azure.com
	clouderatest-mn2.westus.cloudapp.azure.com
	clouderatest-dn0.westus.cloudapp.azure.com
	clouderatest-dn1.westus.cloudapp.azure.com
	clouderatest-dn2.westus.cloudapp.azure.com

To connect to the manager node via SSH, use the username and password used for deployment

	ssh testuser@[dnsNamePrefix]-mn0.[region].cloudapp.azure.com

Once the deployment is complete, you can navigate to the Cloudera portal to watch the operation and track it's status. Be aware that the portal dashboard will report alerts since the services are still being installed.

	http://[dnsNamePrefix]-mn0.[region].cloudapp.azure.com:7180

##Notes, Known Issues & Limitations
- All nodes in the cluster have a public IP address.
- The deployment script is not yet idempotent and cannot handle updates (although it currently works for initial provisioning only)
- SSH key is not yet implemented and the template currently takes a password for the admin user
