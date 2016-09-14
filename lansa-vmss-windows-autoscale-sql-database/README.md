### Autoscale a LANSA Windows VM Scale Set with Azure SQL Database ###

This template deploys a LANSA Windows VM Scale Set integrated with Azure autoscale and Azure SQL Database

The template deploys a Windows VMSS with a desired count of VMs in the scale set and a LANSA MSI to install into each VM. Once the VM Scale Set is deployed a custom script extension is used to install the LANSA MSI

The Autoscale rules are configured as follows
- sample for CPU (\\Processor\\PercentProcessorTime) in each VM every 1 Minute
- if the Percent Processor Time is greater than 60% for 5 Minutes, then the scale out action (add 10% more VM instances) is triggered
- once the scale out action is completed, the cool down period is 20 Minutes
- if the Percent Processor Time is less than 30% for 5 Minutes, then the scale in action (remove one VM instance) is triggered
- once the scale in action is completed, the cool down period is 5 Minutes

#### Prerequisites ####

Before deploying this template you must:
- Subscribe to the LANSA Scalable License
- Upload your LANSA Web Application MSI to Azure BLOB storage and obtain the URL of the MSI. Note that the template includes a demonstration application so it is not strictly necessary to create a LANSA MSI in order to use the template.
- Its also highly recommended to follow the usage instructions below :)

#### Usage Instructions ####

For full instructions for using this template go to [Azure Deployment Tutorial](http://docs.lansa.com/14/en/lansa022/index.htm#lansa/vldtoolct_0250.htm#_Toc461606162%3FTocPath%3DLANSA%2520Application%2520Deployment%2520Tool|Cloud%2520Tutorials|Microsoft%2520Azure%2520Tutorial|_____0)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Frobe070%2Fazure-quickstart-templates%2Ffeature%2Flansastack%2Flansa-vmss-windows-autoscale-sql-database%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Frobe070%2Fazure-quickstart-templates%2Ffeature%2Flansastack%2Flansa-vmss-windows-autoscale-sql-database%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Tags: 'lansa, vmss, sql, autoscale, windows'

#### Notes ####

1. Two VMSS. One to install the database; 1 to run the web site. OverProvision = false. This is so that extra VMs are not created which would put more load on the database which slows down provisioning. Failure to provision has not been seen. If it occurs, the VMSS will ensure another VM is created to establish the correct InstanceCount. A second reason is that the database installer VMSS MUST NEVER have more than 1 instance installing at a time. Errors occur when publishing the weblets. As well as the database state not being matched to what the VM thinks the state of the database is in terms of table creation, etc.
  1. Database VMSS
	1. Only 1 instance ever. If instance dies another one is created.
	2. This instance is not currently used by the web site as 1 load balancer may only be configured for a single VMSS.
	3. Installed with SUDB=1. Otherwise commandToExecute is identical.
  2. Web Site VMSS
	1. Creator of stack specifies the minimum and maximum number of instances for autoscaling.
	2. The minimum number of instances is also the starting capacity for the VMSS. Scaling events alter the VMSS capacity which in turn causes a vm to be created or deleted in order to being the current instance count in line with the VMSS capacity.
	3. Installed with SUDB=0. Otherwise commandToExecute is identical.

2. Scale Out fast. Scale Out action is 10% of current instances. It scales out after 5 mins of avg CPU > 60%. Another scaling event will not occur for 20 minutes. This allows time for the VM to be installed.

3. Scale in slowly. Scale in action is 1 VM at a time after 5 mins of avg CPU < 30%. Another scaling event will not occur for 5 mins. Deletion does not take very long. Allows more VMs to be deleted or another to be created.

