# Intel Lustre 2.7 clients on CentOS 6.6 or 7.0 gallery image

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/intel-lustre-clients-on-centos/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/intel-lustre-clients-on-centos/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/intel-lustre-clients-on-centos/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/intel-lustre-clients-on-centos/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/intel-lustre-clients-on-centos/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/intel-lustre-clients-on-centos/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fintel-lustre-clients-on-centos%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fintel-lustre-clients-on-centos%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template creates Lustre client and server node VMs and related infrastructure such as VNETs. Provided below are the relevant details of the deployment.

* 3 or more Luster servers which consists of MGS (management server), MDS (metadata server) and 1 or more OSS (object storage server).
* OSS Servers are added in an availability set for HA
* It also creates a file system along with the Luster servers. 
* Creates 2 or more Intel Lustre 2.7 client virtual machines using Azure gallery CentOS 6.6 or 7.0 image and mounts an existing Intel Lustre file-system
* These Lustre client nodes are added in an availability set for HA
* Public IP will be attached to the client0 node. That node can be accessed via SSH [dnsNamePrefix].[region].cloudapp.azure.com.

