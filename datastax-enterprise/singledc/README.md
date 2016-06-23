This template deploys a DataStax Enterprise (DSE) cluster to Azure running on Ubuntu virtual machines in a single datacenter.  The template can provision a cluster from 1 to 40 nodes.  Creating a greater number of nodes may cause issues with storage account I/O contention.

The template also provisions a storage account, virtual network and public IP addresses required by the installation.  The template will deploy to the location that the resourceGroup it is part of is located in.

The button below will deploy this template to Azure.  The template will be dynamically linked directly from this github repository.  Given that, if you want to make changes to subtemplates or extensions, be sure to fork the repo and adjust the baseUrl.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FDSPN%2Fazure-resource-manager-dse%2Fmaster%2Fsingledc%2FmainTemplate.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

The template expects the following parameters:

| Name   | Description |
|:--- |:---|
| nodeCount | Number of virtual machines to provision for the cluster |
| vmSize | Size of virtual machine to provision for the cluster |
| adminUsername  | Admin user name for the virtual machines |
| adminPassword  | Admin password for the virtual machines |

Once the Azure VMs, virtual network and storage are setup, the template installs Java and DSE on the nodes.  It also configures them.  These nodes are assigned both private and public dynamic IP addresses.

The template also sets up a node to run DataStax OpsCenter.  The script opscenter.sh installs OpsCenter and connects to the cluster by calling the OpsCenter REST API.

On completion, OpsCenter will be accessible on port 8888 of the public IP address of the OpsCenter node.
