# Puppet Enterprise on Azure with RHEL & Windows Nodes 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpuppet-enterprise-rhel-win%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpuppet-enterprise-rhel-win%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a> 
<br> <br>
<!-- TOC -->

1. [Solution Overview](#solution-overview)
2. [Template Solution Architecture ](#template-solution-architecture)
3. [Licenses and Costs ](#licenses-and-costs)
4. [Prerequisites](#prerequisites)
5. [Deployment Steps](#deployment-steps)
6. [Deployment Time](#deployment-time)
7. [Support](#support)

<!-- /TOC -->

## Solution Overview 
This quickstart template deploys a Puppet Enterprise Solution on Azure Virtual Machine running Ubuntu 14.04 with pre-configured puppet agents running RHEL 7.2 and Windows Server 2016. Template will build everything starting from Azure Infrastructure components to Puppet Master, multiple Windows and RHEL puppet Agents VM's deployment, agent installation, configuration etc. 
To start with, this template will deploy one Puppet Master Server and multiple RHEL and Windows Agent VMs as specified in parameter values during deployment.

Puppet Enterprise is the leading platform for automatically delivering, operating and securing your infrastructure – no matter where it runs. With Puppet you know exactly what is going on with all your software. And you get the automation needed to drive change with confidence. 

Once deployment finishes, you will able to  access Puppet Master Console UI and start using Puppet.

## Template Solution Architecture 

This template will deploy: 

- Four storage accounts 
-	One Virtual Network with three subnets
-	Three Network Security Groups, one for each subnet
-	2 Public IP’s, one for Puppet Master VM and other for Load Balancer.
- One Load Balancer to facilitate RDP and SSH access (via NAT Rules) to puppet agent servers.
-	2 Virtual Machines Availability set's for puppet master and agent vms.
-	One Puppet Master Virtual Machine (Ubuntu 14.04)
-	Multiple Red Hat Linux Puppet Agent Virtual Machines (RHEL 7.2)
-	Multiple Windows Puppet Agent Virtual Machines (Windows Server 2016 Datacenter)
-	Installation and configuration of Puppet Master Server and Agents


![Deployment Solution Architecture](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/puppet-enterprise-rhel-win/images/puppet-enterprise-architecture.png?raw=true)

## Licenses and Costs 

This uses RHEL 7.2 image which is a PAY AS YOU GO image and doesn't require the user to license it, it will be licensed automatically after the instance is launched first time and user will be charged hourly in addition to Microsoft's Linux VM rates.  Click [here](https://azure.microsoft.com/en-gb/pricing/details/virtual-machines/linux/#red-hat) for pricing details.

A complimentary license for Puppet Enterprise is included with this template which can be used to manage upto 10 nodes. Should you need to manage more than 10 nodes, contact [Puppet Sales](https://puppet.com/company/contact-sales?ccn=product-puppet_enterprise&cid=701G0000000FblQ&ls=puppet-enterprise).

## Prerequisites 

Azure Subscription with specified payment method (RHEL 7.2 & Puppet is a market place product and requires payment method to be specified in Azure Subscription)


## Deployment Steps  

Build your Puppet Enterprise environment on Azure in a few simple steps:  

- Launch the Template by clicking on Deploy to Azure button.  
- Fill in all the required parameter values. Accept the terms and condition on click Purchase. 
- Access the deployment job once it is successful. In deployment job output you will find the Public IP Address and FQDN  of master VM which can be used to connect to the Puppet Console. Make a note of the FQDN of Puppet Master VM.Deployment will also output the public IP of load balancer, which can be used to connect to agents VM's via SSH or RDP as applicable.
- Access Puppet Console with the fqdn of master vm noted in above step by accessing https://fqdn
- Login with username as ‘admin’ and password specified in parameters during deployment. 
- You will now have access to working Puppet Master. 
- Follow the post deployment configuration document [here](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/puppet-enterprise-rhel-win/images/puppet-post-deployment-guide.pdf) for further configuration. 

## Deployment Time
The deployment takes about 20 minutes to complete. 


## Support 

For any support related questions, issues or customization requirements, please contact info@spektrasystems.com
