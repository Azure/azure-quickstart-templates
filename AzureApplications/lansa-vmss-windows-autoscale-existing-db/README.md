# Autoscale a LANSA Windows VM Scale Set using an existing database server

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Flansa-vmss-windows-autoscale-existing-db%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Flansa-vmss-windows-autoscale-existing-db%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a Windows Virtual Machine Scale Set with a desired count of Virtual Machines in the scale set and a LANSA MSI to install into each Virtual Machine. Once the Virtual Machine Scale Set is deployed a custom script extension is used to install the LANSA MSI. The database server must already exist. The database within the database server must already exist too, unless its SQL Server, in which case it will be created. If the database does exist it must either not have any LANSA tables or already have had the same MSI installed. This is not checked by the template. Once this template has been run, it must be the only way that an upgrade to the MSI is applied. Two different MSI installs should not attempt to upgrade a LANSA install. This is very important in order that the SQL tables are upgraded correctly. Current databases supported are Azure SQL Database, Microsoft SQL Server and MySql

Tags: 'lansa, vmss, sql, autoscale, windows, sqlserver, mysql'

| Endpoint        | Version           | Validated  |
| ------------- |:-------------:| -----:|
| Microsoft Azure      | - | yes |
| Microsoft Azure Stack      | TP2      |  incompatible |

## Solution overview and deployed resources

The Autoscale rules are configured as follows
- sample for Percentage CPU in each VM every 1 Minute
- if the Percentage CPU is greater than 60% for 5 Minutes, then the scale out action (add 10% more Virtual Machine instances) is triggered
- once the scale out action is completed, the cool down period is 20 Minutes
- if the Percentage CPU is less than 30% for 5 Minutes, then the scale in action (remove one Virtual Machine instance) is triggered
- once the scale in action is completed, the cool down period is 20 Minutes

### Resources Deployed
+	A Virtual Network
+	Six Storage Accounts for deploying up to 100 virtual machines
+	Two public ip addresses, one for each Load Balancer
+	Two external Load Balancers
+	One Virtual Machine Scale Set to contain the single virtual machine which is responsible for configuring the database
+	One Virtual Machine Scale Set to contain the number of web servers requested by the deployer
+	The Virtual Machines are all instantiated from the Marketplace LANSA SKU lansa-scalable-license. There is a software cost for using this image. [Click here](https://azure.microsoft.com/en-us/marketplace/partners/lansa/lansa-scalable-license/) for details.

## Prerequisites

Before deploying this template you must:
- Create a [LANSA supported database server](http://www.lansa.com/support/supportedversions.htm#platforms). Basic instructions are provided [here](http://docs.lansa.com/14/EN/lansa041/Content/lansa/L4WInsb4_0230.htm).
- Construct your LANSA application using [Visual LANSA for Web Development](https://azure.microsoft.com/en-us/marketplace/partners/lansa/visuallansa/) Version 14.1 with EPCs 141010, 141011 and 141013 applied, or later.
- Construct a deployment image MSI using the LANSA Deployment Tool provided with [Visual LANSA for Web Development](https://azure.microsoft.com/en-us/marketplace/partners/lansa/visuallansa/).
- Upload your LANSA Web Application MSI to Azure BLOB storage and obtain the URL of the MSI. Note that the template includes a demonstration application so it is not strictly necessary to create a LANSA MSI in order to use the template.
- Its also highly recommended to follow the usage instructions below :)

## Usage Instructions

For full instructions for using this template go to [Azure Deployment Tutorial](http://docs.lansa.com/14/en/lansa022/index.htm#lansa/vldtoolct_0250.htm#_Toc461606162%3FTocPath%3DLANSA%2520Application%2520Deployment%2520Tool|Cloud%2520Tutorials|Microsoft%2520Azure%2520Tutorial|_____0)


## Notes

1. Two VMSS. One to install the database; 1 to run the web site. OverProvision = false. This is so that extra VMs are not created which would put more load on the database which slows down provisioning. Failure to provision has not been seen. A second reason is that the database installer VMSS MUST NEVER have more than 1 instance installing at a time. Errors occur when publishing the weblets. As well as the database state not being matched to what the VM thinks the state of the database is in terms of table creation, etc.
  1. Database VMSS
	1. Only 1 instance ever. If instance dies another one is created.
	2. This instance is not currently used by the web site as 1 load balancer may only be configured for a single VMSS.
	3. Installed with SUDB=1. Otherwise commandToExecute is identical.
  2. Web Site VMSS
	1. Creator of stack specifies the minimum and maximum number of instances for autoscaling.
	2. The minimum number of instances is also the starting capacity for the VMSS. Scaling events alter the VMSS capacity which in turn causes a vm to be created or deleted in order to bring the current instance count in line with the VMSS capacity.
	3. Installed with SUDB=0. Otherwise commandToExecute is identical.

2. Scale Out fast. Scale Out action is 10% of current instances. It scales out after 5 mins of avg CPU > 60%. Another scaling event will not occur for 20 minutes. This allows time for the VM to be installed.

3. Scale in slowly. Scale in action is 1 VM at a time after 5 mins of avg CPU < 30%. Another scaling event will not occur for 20 mins. Deletion does not take very long. Allows more VMs to be deleted or another to be created.

