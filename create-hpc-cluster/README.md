# Create HPC Cluster

Create HPC Cluster - <a href="https://azuredeploy.net/" target="_blank">
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
| vmStorageAccountContainerName | Storage Blob container to store VM VHD files |
| headNodeSourceImage | Head node source image, default is HPC Pack 2012 R2 Update 1 |
| computeNodeSourceImage | Compute node base image, default is Windows Server 2012 R2 |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machines  |