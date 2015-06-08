# Deploy a slurm cluster

Built by: [YidingZhou](https://github.com/YidingZhou)

##Deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fslurm%2Fazuredeploy.json" target="_blank">
   <img alt="Deploy to Azure" src="http://azuredeploy.net/deploybutton.png"/>
</a>

1. Fill in the 3 mandatory parameters - public DNS name, a storage account to hold VM image, and admin user password.

2. Fill in other info and click "OK".

## Using the cluster

Simply SSH to the master node and do a srun! The DNS name is _**dnsName**_._**location**_.cloudapp.azure.com, for example, yidingslurm.westus.cloudapp.azure.com.

## Parameters

| Name   | Description    |
|:--- |:---|
| dnsName | Unique public dns name where the master node will be exposed | 
| newStorageAccountName | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed |
| adminPassword | password of the admin user |
| vmSize | Instance size of the VM worker node |
| scaleNumber | Number of work nodes in the SLURM cluster |
| location | This is the location where the availability set will be deployed |
| masterVMName | The machine name of the master node - not be confused with dnsName which is public visible name. |
| workerVMName | The machine name of the worker node. |
| adminUserName | User name for the Virtual Machine. |



