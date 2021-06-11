# DDoS Protection attack on a Virtual Machine Scenario 

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ddos-attack-prevention/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ddos-attack-prevention/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ddos-attack-prevention/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ddos-attack-prevention/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ddos-attack-prevention/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ddos-attack-prevention/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fddos-attack-prevention%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)]( https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fddos-attack-prevention%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fddos-attack-prevention%2Fazuredeploy.json)
 
 
# Table of Contents
1. [Objectives](#objectives)
2. [Overview](#overview)
3. [Pre-requisites](#prerequisites)
5. [Perform Attack](#attack)
6. [Detect and Mitigate Attack](#detect)
8. [Configuration validation](#config)
9. [Teardown Deployment](#teardown)

<a name="objectives">
# Objective of the POC  
This playbook illustrates a simulated Distributed Denial of Service (DDoS) attack against a virtual machine.  Work through the configuration setting to enable DDOS protections and get alerted when attacks occur. 

# Overview
Perform DDoS attack on resources in a virtual network having public IP addresses associated with virtual machines with DDoS Protection Standard to detect, mitigate and send alert on being attacked.

<a name="important-notes">

# Important Notes
DDoS Protection Standard protects resources in a virtual network including public IP addresses associated with virtual machines, load balancers, and application gateways. When coupled with the Application Gateway web application firewall, DDoS Protection Standard can provide full layer 3 to layer 7 mitigation capability.  
Refer [Azure DDoS Protection Standard](https://docs.microsoft.com/en-us/azure/virtual-network/ddos-protection-overview) for more details.

<a name="prerequisites">

# Prerequisites
Access to Azure subscription to deploy following resources

1.  Virtual Machine with Virtual Network
2.  OMS (Monitoring)

<a name="attack">

# Perform Attack 
 ### * Attack VM with Basic DDoS protection & analyze <br />
Microsoft have partnered with [BreakingPoint Cloud](https://www.ixiacom.com/products/breakingpoint-cloud) to offer tooling for Azure customers to generate traffic load against DDoS Protection enabled public endpoints to simulate TCP SYN flood and DNS flood attack on the VM without DDoS Protection Standard. Create a  support request with [BreakingPoint Cloud](https://www.ixiacom.com/products/breakingpoint-cloud) for simulation of a DDoS attack on infrastructure. The team executed TCP SYN flood and DNS flood attack on the VM without DDoS Protection Standard  <br />

In this case DDoS attack cannot be detected as shown in below images. <br />
To monitor from metrics to find public IP is under DDoS attack (Does not detect DDoS attack)  <br />
    Azure Portal-->Resource Group --> VM --> Metrics --> Select below options  <br />
    - Select specific Public IP in resource option   <br />
    - "Under DDoS attack or not" in metrics filter  <br />
    

   ![](images/without-ddos-protection-under-attack.png)

To monitor from metrics to find public IP inbound packets status (Does not detect DDoS attack) <br />
    Azure Portal-->Resource Group --> VM --> Metrics --> Select below options from metrics filter  <br />
    - inbound packets DDoS  <br />
    - inbound packets dropped DDoS  <br />
    - inbound packets forwarded DDoS  <br />

  ![](images/without-ddos-protection-inbound.png)

 ### * Attack on VM with DDoS Protection Standard <br />
 
Microsoft have partnered with [BreakingPoint Cloud](https://www.ixiacom.com/products/breakingpoint-cloud) to offer tooling for Azure customers to generate traffic load against DDoS Protection enabled public endpoints to simulate TCP SYN flood and DNS flood attack on the VM without DDoS Protection Standard. Create a  support request with [BreakingPoint Cloud](https://www.ixiacom.com/products/breakingpoint-cloud) for simulation of a DDoS attack on infrastructure. The team executed TCP SYN flood and DNS flood attack on the VM with DDoS Protection Standard <br />

*  To create standard DDoS plan and configure with virtual network <br />

    a. Go to Azure Portal --> Click on "Create a resource" --> Search "DDoS Protection  plan"

      ![](images/ddos-standard-plan-1.png)
    
    b. Enter details and click Create

      ![](images/ddos-standard-plan-2.png)

    c. Configure standard DDoS protection plan on VNet

      ![](images/select-standard-ddos-on-vnet.png)

<a name="detect">

# Detect and mitigate attack
The DDoS attack on VM with DDoS Protection Standard is detected and mitigated as shown in below images. <br />
To monitor from metrics to find public IP is under DDoS attack (Detect DDoS attack)  <br />
    Azure Portal-->Resource Group --> VM --> Metrics --> Select below options  <br />
    - Select specific Public IP in resource option   <br />
    - "Under DDoS attack or not" in metrics filter  <br />
 

   ![](images/monitoring-public-IP-under-DDoS-attack.png)

To monitor from metrics to find public IP inbound packets status (Detect DDoS attack) <br />
    Azure Portal-->Resource Group --> VM --> Metrics --> Select below options from metrics filter  <br />
    - inbound packets DDoS  <br />
    - inbound packets dropped DDoS  <br />
    - inbound packets forwarded DDoS  <br />

  
   ![](images/monitoring-inbound-packets-DDoS.png)

The DDoS Protection Standard detects and mitigates the attack on VM. The below image of network metrics of VM while network in attack. <br />
To monitor network in and network out follow below steps <br />
    Azure Portal-->Resource Group --> VM --> Metrics --> Select VM name in resource --> select network in / out in metrics filter

   ![](images/monitoring-network-in-out.png)
    

The email alert configured at metrics level, this will send the alert mail if VNet is under DDoS attack over last the 5 minutes <br />
  ( Note: Deployment username is used to get the email alert for DDoS attack)
  
    
   ![](images/ddoS-attack-mail-alert.png)

<a name="config">
## Configuration Validation
* Distributed denial of service (DDoS) attacks are some of the largest availability and security concerns facing customers that are moving their applications to the cloud. A DDoS attack attempts to exhaust an application’s resources, making the application unavailable to legitimate users. Azure DDoS protection, combined with application design best practices, provide defense against DDoS attacks. Automatic detection and remediation procedure of such vulnerabilities can be easily done using the controls available in Cloudneeti.

* Cloudneeti is available on the Azure marketplace. Try out the free test drive here https://aka.ms/Cloudneeti

<a name="teardown">
## Teardown Deployment 

Run following powershell command after login to subscription to clear all the resources deployed during the demo. Specify resource group name given during deployment
 
 `Remove-AzureRmResourceGroup -Name <ResourceGroupName>  -Force `
 
    
Verification steps -
1. Login to Azure Portal / Subscription
2. Check if resource group name given during deployment is cleared.
<p/>

**References** 

1.	DDoS Blog: http://aka.ms/ddosblog
2.	DDoS Protection overview: http://aka.ms/ddosprotectiondocs
3.	DDoS Standard best practices & reference architecture: http://aka.ms/ddosbest 

## Disclaimer & Acknowledgements

Avyan Consulting Corp conceptualized and developed the software in guidance and consultations with Microsoft Azure Security Engineering teams.

AVYAN MAKES NO WARRANTIES, EXPRESS, IMPLIED, OR STATUTORY, AS TO THE INFORMATION IN THIS DOCUMENT. This document is provided “as-is.” Information and views expressed in this document, including URL and other Internet website references, may change without notice. Customers reading this document bear the risk of using it. This document does not provide customers with any legal rights to any intellectual property in any AVYAN or MICROSOFT product or solutions. Customers may copy and use this document for internal reference purposes.

### Note:

*	Certain recommendations in this solution may result in increased data, network, or compute resource usage in Azure. The solution may increase a customer’s Azure license or subscription costs.
*	The solution in this document is intended as reference samples and must not be used as-is for production purposes. Recommending that the customer’s consult with their internal SOC / Operations teams for using specific or all parts of the solutions.
*	All customer names, transaction records, and any related data on this page are fictitious, created for the purpose of this architecture, and provided for illustration only. No real association or connection is intended, and none should be inferred. 


