# Lustre client and server node VMs deployment

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fintel-lustre-client-server%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/intel-lustre-client-server/azuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>


This template creates Lustre client and server node VMs and related infrastructure such as VNETs. Provided below are the relevant details of the deployment.

* 3 or more Luster servers which consists of MGS (management server), MDS (metadata server) and 1 or more OSS (object storage server).
* OSS Servers are added in an availability set for HA
* It also creates a file system along with the Luster servers. 
* Creates 2 or more Intel Lustre 2.7 client virtual machines using Azure gallery CentOS 6.6 or 7.0 image and mounts an existing Intel Lustre file-system
* These Lustre client nodes are added in an availability set for HA
* Public IP will be attached to the client0 node. That node can be accessed via SSH [dnsNamePrefix].[region].cloudapp.azure.com.
* To run this template you must first deploy a Lustre cluster in your subscription and use the existing virtual network when deploying the clients and server.
* The required artifacts for deploying the Lustre cluster and virtual network are in prerequisite folder.
	* Use Azure CLI to login to subscription.
	* Execute the deploy.bat by replacing the arguments in parameters.txt file.
	* Keep deploy.bat and parameters.txt file in same folder.
