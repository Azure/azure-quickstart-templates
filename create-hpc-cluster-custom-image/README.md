# Create HPC Cluster with custom compute node image

# Using HPC published head node image and user custom compute node image
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcreate-hpc-cluster-custom-image%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create one HPC Cluster

# Other Option: Using HPC published head node image, compute node will be auto installed through access head node file share
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcreate-hpc-cluster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create one HPC Cluster

Below are the parameters that the template expectes.

| Name   | Description    |
|:--- |:---|
| namePrefix | The prefix of the resources(storage account, virtual network, virtual machine etc) to be created. |
| location | location where the resources will be deployed |
| headNodeVMSize | Size of the head node Virtual Machine |
| computeNodeNumber | Number of compute nodes to be deployed |
| computeNodeVMSize | Size of the compute node Virtual Machine |
| computeNamePrefix | Compute node name prefix |
| storageAccountType | Storage Account type |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machines  |
| headNodeImagePublisher  | head node image publisher, default is MicrosoftWindowsServerHPCPack, user should keep it as default  |
| headNodeImageOffer  | head node image offer, default is WindowsServerHPCPack, user should keep it as default  |
| headNodeImageSKU  | head node image sku, default is 2012 R2  |
| computeNodeImagePublisher  | compute node image publisher, default is MicrosoftWindowsServer, user should keep it as default  |
| computeNodeImageOffer  | compute node image offer, default is WindowsServer, user should keep it as default  |
| computeNodeImageSKU  | compute node image sku, default is 2012-R2-Datacenter  |
| headNodePostConfigScript  | post config script on head node, if user don't need post config, can ignore it. the format should be with full url and arguments  |
| computeNodePostConfigScript  | post config script on compute node, if user don't need post config, can ignore it. the format should be with full url and arguments  |
