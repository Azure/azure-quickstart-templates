# Create a 3-node, CentOS elasticsearch cluster


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Felasticsearch-centos-3node%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Felasticsearch-centos-3node%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates an elasticsearch cluster of 3 CentOS nodes and a Windows jumpbox that are ideal for getting started with elastic in Azure. 



## Resources

The following resources are created by this template:

- 3 Linux VM's for the elastic cluster 
- 1 Windows VM used as a jumpbox that has a public IP
- 1 virtual network with 2 subnets; one for the jumpbox which has an NSG, one for the elastic cluster
- 1 storage account for the VHD files and the elastic snapshot repository

**The elastic subnet does not have an NSG because it needs to download packages from the internet to get set-up. After setting up your environment, you will likely want to create an NSG for this subnet. 


## elastic cluster

The 3 Linux VM's are:

- Standard D1 size
- CentOS 7.1
- An OS Disk and a 1 TB data disk

A Custom Script Extension resource is created that runs a Python script on each VM: elasticinstall.py 

**Python is used because it is already installed and easy to understand. 

This script does the following:

- Installs Java 1.8 (openjdk)
- Installs elasticsearch version 1.7.3
- Installs elasticsearch HQ plugin
- Installs elasticsearch Azure plugin
- Installs nano
- Configures each node to be both Master and Data
- Configures elastic to use 2 GB of heap
- Formats and mounts the 1 TB data disk and configures elastic to use it for data
- Configures elastic to use unicast and lists each host in the cluster by IP address

**Swap is not configured per elasticsearch recommendation in their documentation, and heap is approximately half of RAM in D1.


## Jumpbox

The Windows jumpbox is:

- Standard D1 size
- Windows Server 2012 R2 Datacenter

A Custom Script Extension resource is created that runs a PowerShell script on this VM: prep-jumpbox.ps1 

This script does the following:

- Disables IE enhanced security configuration
- Downloads Putty to the desktop
- Creates a URL shortcut to HQ on the desktop
- Associates .ps1 with PowerShell ISE
- Downloads a json file with demo data to the desktop (shakespeare.json)
- Copies a PowerShell script called 'get-started.ps1' to the desktop which contains web calls to:
	- Create a snapshot repository in Azure blob storage (the storage account created by the template)
	- Create a demo index for the shakespeare data
	- Index the shakespeare data
	- Query the shakespeare data
	- Create a snapshot of the indices to the Azure blob snapshot repository


## Deployment

After deployment has completed, Remote Desktop to the Jumpbox. The admin user and password will be the same for all VM's. On the Jumpbox you can open the HQ URL link to check that the installation was successful. And then open the get-started.ps1 to start interacting with the cluster.  








