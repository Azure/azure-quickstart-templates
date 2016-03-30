<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcentos-2nics-lb-cluster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcentos-2nics-lb-cluster%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a 2-10-node CentOS 6.5 cluster using the [Azure Resource Manager (ARM)](https://azure.microsoft.com/en-us/documentation/articles/resource-group-overview/) "copy" feature. Each node has 2 network cards:

* The first one is on a "public" subnet.
* The second one is on a "private" subnet.

The public subnet is fronted by a load-balancer with one dynamically assigned public IP address and as many NAT ports as there are nodes, starting from port 50000.
The template also asks for a dns name and a location for the ip address.
Thus, if you want to connect to node 0, you'll type:

* ssh \<user\>@\<name\>.\<location\>.cloudapp.azure.com -p 50000

The private network is intended for cluster communications only.

The template also configures:

* A storage account where all the virtual hard disks are stored.
* A virtual network where the private and public subnet reside.

The template invokes a custom bash script that configures the second network card on CentOS nodes. By default the second card is recognized but the network stack is not set up.

The limit on the number of nodes is artificial. Alas, ARM does not support arithmetic operators yet, so one has to list all the possible NAT ports for the load-balancer configuration. I listed 10. Feel free to add more and you'll be able to increase the number of nodes. Also, if not all nodes require external connections, you can have as many nodes as the current subnet limit.
