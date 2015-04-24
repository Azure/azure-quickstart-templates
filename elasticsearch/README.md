# Install Elasticsearch cluster on Virtual Machines with data node storage scale units

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys an Elasticsearch cluster on Virtual Machines and uses template linking to create data node scale untis.  The template provisions 3 dedicated master and client nodes in separate availability sets and storage accounts. Data node scale unit count and nodes in a scale unit can be configured as parameters.  A load balancer is configured with a rule to route traffic on port 9200 to the client nodes, and also includes a single SSH management rule mapped to one of the client nodes.  Multiple data disks are attached (the number depends on the size of the virtual machine selected) and data is striped across them as an approach to improve disk throughput.

This template also deploys a Storage Account, Virtual Network, Availability Sets, Public IP addresses, Load Balancer, and a Network Interface.

Warning!  This template provisions a large number of resources.  At a minimum, with the current defaults, 14 virtual machines and 3 storage accounts are provisioned.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| storageAccountPrefix  | Unique DNS Name for the Storage Account and the template will use this to create at storage account for each data node scale unit.  Keep this short - scale unit and vm are appended this |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameforLBIP  | Unique DNS Name for the Public IP used for load balancer. |
| loadBalancerType | Type of load balancer to place the client nodes on (internal/external) |
| region | region where the resources will be deployed |
| virtualNetworkName | Name of Virtual Network |
| OS | The OS platform to deploy elasticsearch on |
| jumpbox | Add a management box to the deployment |
| vmSizeMasterNodes | Size of the Cluster Master Virtual Machine Instances |
| vmSizeClientNodes | Size of the Cluster Data Virtual Machine Instances |
| vmSizeDataNodes | Size of the Cluster Data Virtual Machine Instances (This will also affect number of data disks) |
| dataNodeScaleUnits | Number of Elasticsearch data scale units which include a configurable number of nodes and a storage account|
| dataNodesPerUnit | Number of Elasticsearch data nodes to provision with each scale unit|
| esClusterName | Name of the Elasticsearch cluster (elasticsearch) |
| esVersion | Elasticsearch version to deploy (1.5.0) |
| dataDiskSize | The size of each data disk attached in Gb (default 100GB) |

##Notes
Security Warning!  The configuration allows you to enabled external load balanced endpoints on a public IP.  The endpoint is not secure and it's recommended that you keep these endpoints internal or secure them. Elasticsearch Sheild product should be considered.

One of the primary advantages to this approach is that you can distribute data nodes across multiple storage accounts.  Changing the virtual machine size for data nodes will affect the amount of storage for each node as it changes the number of data disks that are attached.

The multiple data node templates with varying number of data disks is a temporary workaround until the features are available allowing us to attach a configurable number of data disks.
