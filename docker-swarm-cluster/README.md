# Docker Swarm Cluster




<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmongodb-on-centosdocker-swarm-cluster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Swarm is the clustering technolgy used with Docker to create clusters to deploy our containers. This template deploys the infrastructure to build a cluster with a management node and three cluster nodes. You can customize the number of nodes using the parameters. This template also deploys a Storage Account, Virtual Network, a Public IP address and the Network Interfaces required.

Below are the parameters that the template accepts.

### Parameters you should modify

This parameters are defined by default but they should change to avoid collisions with others resources deployed to Azure by other users.

| Name   | Description    |
|:--- |:---|
| storageAccountName  | The name of the storage account where the virtual hard disks of the VMs are going to be stored. |
| swarmMasterPublicIpDnsName  | "Name of the DNS assigned to the master node to be able to access through internet  |


### Optional parameters to modify

| Name   | Description    |
|:--- |:---|
| location | This is the location where the cluster will be deployed |
| virtualNetworkName  | The name of the virtual network account where the resources will be deployed  |
| virtualNetworkPrefix  | The IP range on CIDR notation of the virtual network where the resource will be deployed  |
| subnetSwarmName  | The name of the virtual network where the swarm nodes will be deployed |
| subnetSwarmPrefix  | The IP range on CIDR notation of the virtual network where the resource will be deployed |
| subnetManageName | The name of the virtual network where the swarm nodes will be deployed |
| subnetManagePrefix | The IP range on CIDR notation of the virtual network where the resource will be deployed |
| swarmNodesNumber | Number of swarm cluster nodes to deploy|
| swarmClusterNodesSize | Size of the VMs for the cluster nodes |
| adminUsername | User name for the root user of the virtual machines |
| adminPassword | Password of the root user account inside the virtual machines |
| swarmMasterPublicIpName | Name of the public Ip assigned to the master node |
| scriptsUri | Public URL to get the .json templates for the deployment |

