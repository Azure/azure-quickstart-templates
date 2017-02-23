# Red Hat Linux 3-tier IaaS Solution on Azure 
## Solution Overview 
This Azure Quick Start template deploys a 3 Tier Red Hat Solution on Azure.The Solution includes Web tier Servers, Application tier Servers and Database Tier Servers running Red Hat Enterprise Linux 7.3. Template follows Standard best practices for running a 3 tier Red Hat Linux IaaS workload on Azure. This template will deploy multiple VMs in each tier as per requirement. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Frhel-3tier-iaas%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Frhel-3tier-iaas%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a> 

 
##Deployment Solution Architecture 

This template will deploy: 

- Five storage accounts: 3 for storing VM's of each tier, 1 for storing diagnostics data and 1 for storing Jump VM.
-	One Virtual Network with four subnets.
- 4 Network Security Groups, one for each subnet.
-	External Load Balancer to load balance Web Traffic(HTTP & HTTPS) to web servers.
- Internal Load Balancer to load balance traffic for app VM's.
-	2 Public IP’s, one for external Load balancer and other for Jump VM. 
-	3 Virtual Machine Availability sets for Web Tier, Application Tier and Database tier.
-	One Jump VM to faclitate ssh access to all other VMs.
-	Multiple Red Hat Enterprise Linux VMs as per parameter value given during deployment for each tier.

![Deployment Solution Architecture](https://github.com/Azure/azure-quickstart-templates/master/rhel-3tier-iaas/images/architecture.png?raw=true)

##Licenses and Costs 

The Red Hat Enterprise Linux 7.3 image used in this solution is the PAYG model and doesn't require the user to license it, it will be licensed automatically after the instance is launched first time. Use of this image carries a separate hourly charge that is in addition to Microsoft's Linux VM rates. Total price of the VM consists of the base Linux VM price plus RHEL VM image surcharge.  Click [here](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/red-hat/) for pricing details.

##Prerequisites 

- Azure Subscription with specified payment method (Red Hat Enterprise Linux is a marketplace product and requires payment method to be specified in Azure Subscription)

##Deployment Steps  

Build your Red Hat 3-Tier IaaS environment on Azure in a two simple steps:  
- Launch the Template deployment by clicking on Deploy to Azure button. 
- Fill in all the required parameter values. Accept the terms and condition on click Purchase. The deployment takes about 5 minutes. 

##Post Deployment Steps 

After successful deployment, this template will output the IP address and FQDN of both external load balancer and Jump VM. Make a note of these values.

- To access all VM's via SSH, you need to first ssh into jump VM using its public ip captured from template outputs, from jump VM you can ssh into other VMs through via their private IP.
  or
- You can also get public IP of Jump VM from overview blade in VM Settings.
- Load balancer is configured for load balancing HTTP(Port 80) and HTTPS(Port 443) to distribute traffic to web servers.You can configure web servers and start access websites using Load Balancer. 

##Support 

For any support related questions or customization requirements, please contact info@spektrasystems.com



