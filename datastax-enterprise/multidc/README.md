multidc is a Python script that generates an ARM template.  This supports multiple data centers and is highly customizable.

deploy.sh is the main entry point.  This takes the name of a resource group as a parameter.  deploy.sh creates that resource group, generates an ARM template by invoking main.py and submits that template to Azure.  The template created is written to ./generatedTemplate.json

main.py reads from the following parameters from ./clusterParameters.json:

| Name   | Description |
|:--- |:---|
| locations | A list of locations to deploy DSE datacenters to |
| nodeCount | The number of DSE nodes to deploy in each datacenter |
| vmSize | The size of virtual machine to provision for each cluster node |
| adminUsername  | Admin user name for the virtual machines |
| adminPassword  | Admin password for the virtual machines |

Once the Azure VMs, virtual network and storage are setup, the template installs Java and DSE on the nodes.  It also configures them.  These nodes are assigned both private and public dynamic IP addresses.

The template also sets up a node to run DataStax OpsCenter.  The script opscenter.sh installs OpsCenter and connects to the cluster by calling the OpsCenter REST API.

On completion, OpsCenter will be accessible on port 8888 of the public IP address of the OpsCenter node.
