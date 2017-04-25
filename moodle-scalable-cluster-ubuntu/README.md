# MoodleAzure
Moodle deployment using Azure Resource Manager Template

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpateixei%2FMoodleAzure%2Fv2%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fpateixei%2FMoodleAzure%2Fv2%2Fazuredeploy.json)


This Azure Resource Manager template creates a clustered moodle environment. 

The following resources will be created:

- a Virtual Machine Scale Set (up to 10 instances) for the web tier, with auto-scale configured
- 02 nodes Gluster Cluster  (2 Premium disks attached, raid0, a gluster brick in each virtual machine)
- 02 nodes MariaDb 10 Active-Active Cluster (Galera Cluster)
- an Internal Load Balancer in front of the MariaDb clustered
- an public Load Balancer in front of the Virtual Machine Scale Set (web tier)
- a virtual machine used as a JumpBox for the environment, acessible via SSH and http
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

Hope it helps.
Feedbacks are welcome.


