# Create HPC Cluster

# Using HPC published head node image
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsunbinzhu%2Fazure-quickstart-templates%2Fmaster%2Fcreate-hpc-cluster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create one HPC Cluster

Below are the parameters that the template expectes.

| Name   | Description    |
|:--- |:---|
| namePrefix | The prefix of the resources(storage account, virtual network, virtual machine etc) to be created. |
| location | location where the resources will be deployed |
| headNodeVMSize | Size of the head node Virtual Machine |
| computeNodeImage | The VM image of the compute nodes |
| computeNodeNumber | Number of compute nodes to be deployed |
| computeNodeVMSize | Size of the compute node Virtual Machine |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machines  |
| headNodePostConfigScript  | post config script on head node, if user don't need post config, can ignore it. the format should be with full url and arguments  |