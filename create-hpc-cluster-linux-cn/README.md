# Create HPC cluster with Linux compute nodes
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcreate-hpc-cluster-linux-cn%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create an HPC cluster with Linux compute nodes.

Below are the parameters that the template expects.

| Name   | Description    |
|:--- |:---|
| clusterName | The unique HPC Pack cluster name. It is also used as the public DNS name prefix for the cluster, for example, the public DNS name is '&lt;clusterName&gt;.westus.cloudapp.azure.com' if the resource group location is 'West US'. It must contain between 3 and 15 characters with lowercase letters and numbers, and must start with a letter. |
| privateDomainName | The fully qualified domain name (FQDN) for the private domain forest which will be created by this template, for example 'hpcdomain.local'. |
| headNodeVMSize | Size of the head node Virtual Machine |
| computeNodeImage | The Linux distro of the Linux compute nodes |
| computeNodeNamePrefix | The name prefix of the compute nodes. It can contain letters, numbers and hyphens, and must start with a letter, up to 13 characters, for example, if 'IaaSLnxCN-' is specified, the compute node names will be 'IaaSLnxCN-0', 'IaaSLnxCN-1', ... |
| computeNodeNumber | Number of compute nodes to be deployed |
| computeNodeVMSize | Size of the compute node Virtual Machine |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machines  |
| headNodePostConfigScript  | Optional, specify the script url and command line if you want to run your custom script on the head node after it is configured. The script url must be public available, and you can also specify arguments for the script, for example 'http://www.consto.com/mypostscript.ps1 -Arg1 arg1 -Arg2 arg2'. |
