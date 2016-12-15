# Install a Redis cluster on Ubuntu Virtual Machines using Custom Script Linux Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fredis-high-availability%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fredis-high-availability%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a Redis cluster on the Ubuntu virtual machines. This template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.
The template also creates 1 publicly accessible VM acting as a "jumpbox" and allowing to ssh into the Redis nodes for diagnostics or troubleshooting purposes.

Topology
--------

The deployment topology is comprised of _numberOfInstances_ nodes running in the cluster mode.
The AOF persistence is enabled by default, whereas the RDB persistence is tuned to perform less-frequent dumps (once every 60 minutes). For more details on Redis persistence options, please refer to the [official documentation](http://redis.io/topics/persistence).

The following table outlines the VM characteristics for each supported t-shirt size:

| T-Shirt Size | VM Size | CPU Cores | Memory | # of Masters | # of Slaves | Total # of Nodes |
|:--- |:---|:---|:---|:---|:---|:---|
| Small | Standard_A1 | 1 | 1.75 GB | 3 | 0 | 3 |
| Medium | Standard_A2 | 2 | 3.5 GB | 3 | 3 | 6 |
| Large | Standard_A5 | 2 | 14 GB | 3 | 6 | 9 |

In addition, some critical memory- and network-specific optimizations are applied to ensure the optimal performance and throughput.

NOTE: To access the individual Redis nodes, you need to enable and use the publicly accessible jumpbox VM and ssh from it into the Redis instances.

##Known Issues and Limitations
- SSH key is not yet implemented and the template currently takes a password for the admin user
- Redis version 3.0.0 or above is a requirement for the cluster (although this template also supports Redis 2.x which will be deployed using a traditional master-slave replication)
- A static IP address (starting with the prefix defined in the _nodeAddressPrefix_ parameter) will be assigned to each Redis node in order to work around the current limitation of not being able to dynamically compose a list of IP addresses from within the template (by default, the first node will be assigned the private IP of 10.0.0.10, the second node - 10.0.0.11, and so on)
