# MoodleAzure
High available, high scalable Moodle deployment using Azure Resource Manager Template

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpateixei%2FMoodleAzure%2Fv2%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fpateixei%2FMoodleAzure%2Fv2%2Fazuredeploy.json)

This Azure Resource Manager template creates a clustered, multi-layered moodle environment. 
With this template we have three main components being deployed: 
- a web application layer with VMSS and auto-scale enabled
- a database layer composed of a MariaDb Galera cluster 
- a shared filesystem layer, for the "moodledata" content.

Main differences from other existing Moodle templates:
- web layer uses a VMScale Set with auto-scale configured, allowing better usage of resources (02 to 10 web nodes possible)
- database layer was built using MariaDb Galera Cluster, in a high-available setup, providing 99.95% SLA
- filesystem layer (MoodleData) was built on top of VMs with Premium Disks, supporting very intensive IO scenarios; also built on top of GlusterFS, a high scalable storage solution from RedHat (see www.glusterfs.org for details), in a High Available setup (data replication accross cluster nodes, also providing a 99.95% SLA).
- Customer can define the size (small, medium, large) for database and filesystem layers 
- Azure Redis Cache is deployed in the solution, to be used as Moodle Session Cache backend (manual setup required in moodle)
- it was built for Moodle 3.x deployments 
- Azure Backup can be enabled for VMS hosting MariaDb Database and Moodledata content (very important for DR scenarios)
- Apache is configured with SSL support (using a self-signed certificate), allowing custom certificates with desired.

Summarizing, the following resources will be created during this process:

- a Virtual Machine Scale Set (up to 10 instances) for the web tier, with auto-scale configured
- 02 nodes Gluster Cluster  (2 Premium disks attached, raid0, a gluster brick in each virtual machine), data replicated accross nodes in a HA setup for the filesystem layer
- 02 nodes MariaDb 10 Active-Active Cluster (Galera Cluster), in a HA setup scenario for the database layer
- an Internal Load Balancer in front of the MariaDb cluster
- an public Load Balancer in front of the Virtual Machine Scale Set (web layer)
- a virtual machine used as a JumpBox for the environment, acessible via SSH
- a redis cache to be used for Moodle Session Cache (manual setup required in Moodle)
- a lot of underlying resources need for the environment (virtual network, storage accounts, etc)

![Moodle On Azure](./images/moodle-on-azure.jpg)

The setup script will ask you about the 't-shirt size' for database & gluster layers.
Here's an explanation for each one of these: 

Gluster t-shirt sizes: 

		tshirt | VM Size         | Disk Count | Disk Size | Total Size
		Small  | Standard_DS2_v2 |  4         |  127 Gb   | 512 Gb
		Medium | Standard_DS3_v2 |  2         |  512 Gb   | 1 Tb
		Large  | Standard_DS4_v2 |  2         | 1023 Gb   | 2 Tb

MariaDb t-shirt sizes: 

		tshirt | VM Size         | Disk Count | Disk Size | Total Size
		Small  | Standard_DS2_v2 |  2         |  127 Gb   | 256 Gb
		Medium | Standard_DS3_v2 |  2         |  512 Gb   | 1 Tb
		Large  | Standard_DS4_v2 |  2         | 1023 Gb   | 2 Tb

*Updating the source code or Apache SSL certificates* 

There's a jumpbox machine in the deployment that can be used to update Moodle's source code, or SSL certificates in the web layer. 
In order to proceed with this kind of update, connect to the machine using the root credentials provided during the template setup. 
- Moodle source code is located at /moodle/html/moodle
- Apache SSL certificates are located at /moodle/certs
- Moodledata content is located at /moodle/moodledata

This template is aimed to have constant updates, and would include other improvements in the future. 

Hope it helps.

Feedbacks are welcome.


