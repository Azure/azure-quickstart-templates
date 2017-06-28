# Barracuda WAF on Azure 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbarracuda-waf-iis%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbarracuda-waf-iis%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a> 
<br><br>

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
This Azure Quick Start template deploys a Barracuda Web Application Firewall Solution on Azure.  The Solution includes Barracuda WAF Appliance and backend web servers running Windows Server 2012 R2 with IIS. Template will build everything starting from Azure Infrastructure components to Barracuda deployment and Windows VM deployment with automated IIS Web Server installation. This template will deploy one Barracuda WAF VM and multiple backend web servers as per requirement. 

The Barracuda Web Application Firewall inspects inbound web traffic and blocks SQL injections, Cross-Site Scripting, malware uploads & application DDoS and other attacks targeted at your web applications. It also inspects the responses from the back-end web servers for Data Loss Prevention (DLP). The integrated access control engine enables administrators to create granular access control policies for Authentication, Authorization & Accounting (AAA), which gives organizations strong authentication and user control. The onboard L4/L7 Load Balancing capabilities enable organizations to quickly add back-end servers to scale deployments. Application acceleration capabilities including SSL Offloading, caching, compression, and connection pooling, ensure faster application delivery of web application content. 

Once deployment finishes, you will able to directly access fully configured Barracuda GUI and start publishing your web applications.

## Template Solution Architecture 

This template will deploy: 

- Two storage accounts 
-	One Virtual Network with two subnets
-	One Load Balancer to facilitate RDP access (via NAT Rules) to backend web servers
-	2 Public IP’s, one for Barracuda WAF and one for the Load Balancer
-	Virtual Machines Availability set for Barracuda and Backend Web server VMs.
-	One Barracuda Web Application Firewall VM
-	Two Windows Server 2012 R2 VMs
-	Automated deployment of IIS in Windows VM’s

![Deployment Solution Architecture](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/barracuda-waf-iis/images/barracuda-architecture.png?raw=true)

## Licenses and Costs 

This Barracuda Web Application Firewall is the PAYG model and doesn't require the user to license it, it will be licensed automatically after the instance is launched first time and user will be charged hourly for Barracuda Web Application Firewall Software on Microsoft. Click [here](https://azure.microsoft.com/en-us/marketplace/partners/barracudanetworks/waf/#hourly) for pricing details.

## Prerequisites 

Azure Subscription with specified payment method (Barracuda WAF is a market place product and requires payment method to be specified in Azure Subscription)

## Deployment Steps  

Build your Barracuda WAF environment on Azure in a few simple steps:  
- Launch the Template by click on Deploy to Azure button.  
- Fill in all the required parameter values. Accept the terms and condition and click on Purchase. 
- Follow the post deployment configuration document [here](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/barracuda-waf-iis/images/barracuda-waf-post-deployment-configuration-guide.pdf) for further configuration. 

## Deployment Time  

The deployment takes about 30 minutes. 

## Support 

For any support related questions, issues or customization requirements, please contact info@spektrasystems.com



